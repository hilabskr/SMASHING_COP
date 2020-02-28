using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "User", AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/chat-message/")]
    public class Api_1_0_ChatMessageController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_ChatMessageController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpPost("{chatRoomId}/add")]
        public async Task<IActionResult> Add(long chatRoomId, [FromForm] string message)
        {
            if (IsDebug) await Task.Delay(1500);

            var myUserId = User.FindFirstValue("myUserId");

            if (chatRoomId == 0 || message == null) return BadRequest();
            if (message.Trim().Length < 2) return Ok(new { isSuccess = false, responseMessage = "메시지를 2글자 이상 입력해주세요" });
            if (message.Trim().Length > 4000) return Ok(new { isSuccess = false, responseMessage = "메시지를 4000글자 이하로 입력해주세요" });

            var chatRoom = _context.ChatRoom.Include(m => m.User1).Include(m => m.User2).Include(m => m.LastChatMessage).SingleOrDefault(m => m.ChatRoomId == chatRoomId);
            if (chatRoom == null) return NotFound();

            if (chatRoom.User1.UserId != myUserId && chatRoom.User2.UserId != myUserId) return BadRequest();

            var friendUserId = (chatRoom.User1.UserId == myUserId) ? chatRoom.User2.UserId : chatRoom.User1.UserId;
            var userFriend = _context.User.AsNoTracking().SingleOrDefault(m => m.UserId == friendUserId);
            if (userFriend == null) return BadRequest();

            bool isNewDay = false;

            if (chatRoom.LastChatMessage == null ||
                chatRoom.LastChatMessage.InsertedAt.ToString("yyyy-MM-dd") != DateTime.Now.ToString("yyyy-MM-dd"))
            {
                isNewDay = true;
            }

            bool isBlinded = false;
            var relationshipScore = _context.RelationshipScoreFriend.SingleOrDefault(m => m.UserId1 == friendUserId && m.UserId2 == myUserId)?.ReferenceScore ?? -1;
            if (relationshipScore != -1 && relationshipScore < 50) isBlinded = true;

            var newChatMessage = new ChatMessage
            {
                ChatRoom = chatRoom,
                User = _context.User.SingleOrDefault(m => m.UserId == myUserId),
                Message = message.Trim(),
                IsNewDay = isNewDay,
                IsBlinded = isBlinded,
                InsertedAt = DateTime.Now,
            };
            _context.Add(newChatMessage);

            if (chatRoom.User1.UserId == myUserId) chatRoom.User2NewCount++;
            if (chatRoom.User2.UserId == myUserId) chatRoom.User1NewCount++;
            chatRoom.UpdatedAt = DateTime.Now;
            chatRoom.LastChatMessage = newChatMessage;

            _context.SaveChanges();

            if (isBlinded == false)
            {
                var userMe = _context.User.AsNoTracking().SingleOrDefault(m => m.UserId == myUserId);
                SendPushNotification(_context, userFriend.UserId, "NEW_CHAT_MESSAGE=" + chatRoom.ChatRoomId, userMe.UserName, message.Cut(20, ".."));
            }

            return Ok(new { isSuccess = true });
        }

        [HttpGet("{chatRoomId}/list")]
        public async Task<IActionResult> List(long chatRoomId, int? after, int? before)
        {
            if (IsDebug) await Task.Delay(1500);

            var myUserId = User.FindFirstValue("myUserId");

            if (chatRoomId == 0) return BadRequest();
            var chatRoom = _context.ChatRoom.Include(m => m.User1).Include(m => m.User2).SingleOrDefault(m => m.ChatRoomId == chatRoomId);
            if (chatRoom == null) return NotFound();

            if (chatRoom.User1.UserId != myUserId && chatRoom.User2.UserId != myUserId) return BadRequest();

            var source = _context.ChatMessage.AsNoTracking().Include(m => m.User).Where(m => m.ChatRoom.ChatRoomId == chatRoomId);

            if (after != null) source = source.Where(m => m.ChatMessageId < after).OrderByDescending(m => m.ChatMessageId).Take(30);
            else if (before != null) source = source.Where(m => m.ChatMessageId > before).OrderByDescending(m => m.ChatMessageId);
            else source = source.OrderByDescending(m => m.ChatMessageId).Take(30);

            bool isNewCountUpdated = false;

            if (after == null)
            {
                if (chatRoom.User1.UserId == myUserId && chatRoom.User1NewCount > 0)
                {
                    chatRoom.User1NewCount = 0;
                    chatRoom.UpdatedAt = DateTime.Now;
                    _context.SaveChanges();
                    isNewCountUpdated = true;
                }
                else if (chatRoom.User2.UserId == myUserId && chatRoom.User2NewCount > 0)
                {
                    chatRoom.User2NewCount = 0;
                    chatRoom.UpdatedAt = DateTime.Now;
                    _context.SaveChanges();
                    isNewCountUpdated = true;
                }
            }

            var listChatMessage = source.Select(m => new
            {
                m.ChatMessageId,
                message = (m.User.UserId != myUserId && m.IsBlinded == true) ? BlindedChatMessage : m.Message,
                m.IsNewDay,
                m.InsertedAt,
                isMyMessage = (m.User.UserId == myUserId),
            }).ToList();

            return Ok(new
            {
                isNewCountUpdated,
                listChatMessage,
            });
        }
    }
}
