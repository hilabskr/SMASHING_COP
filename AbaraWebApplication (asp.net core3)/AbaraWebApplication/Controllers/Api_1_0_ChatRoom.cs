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
    [Route("/api/v{version:apiVersion}/chat-room/")]
    public class Api_1_0_ChatRoomController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_ChatRoomController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("open/{friendUserId}")]
        public async Task<IActionResult> Add(string friendUserId)
        {
            if (IsDebug) await Task.Delay(500);

            var myUserId = User.FindFirstValue("myUserId");

            if (myUserId == friendUserId) return Ok(new { isSuccess = false, responseMessage = "다른 사람을 선택하면 대화를 시작할 수 있습니다" });

            var userFriend = _context.User.SingleOrDefault(m => m.UserId == friendUserId);
            if (userFriend == null) return BadRequest();

            var chatRoom = _context.ChatRoom.AsNoTracking().SingleOrDefault(m => (m.User1.UserId == myUserId && m.User2.UserId == friendUserId) || (m.User1.UserId == friendUserId && m.User2.UserId == myUserId));
            if (chatRoom == null)
            {
                chatRoom = new ChatRoom
                {
                    User1 = _context.User.SingleOrDefault(m => m.UserId == myUserId),
                    User2 = userFriend,
                    User1NewCount = 0,
                    User2NewCount = 0,
                    CreatedAt = DateTime.Now,
                    UpdatedAt = DateTime.Now,
                    LastChatMessage = null,
                };
                _context.Add(chatRoom);
                _context.SaveChanges();
            }

            return Ok(new
            {
                isSuccess = true,
                chatRoom = new { chatRoom.ChatRoomId },
            });
        }

        [HttpGet("list")]
        public async Task<IActionResult> List()
        {
            if (IsDebug) await Task.Delay(500);

            var myUserId = User.FindFirstValue("myUserId");

            var source = _context.ChatRoom.AsNoTracking().Include(m => m.User1).Include(m => m.User2).Include(m => m.LastChatMessage).Where(m => m.User1.UserId == myUserId || m.User2.UserId == myUserId);

            source = source.OrderByDescending(m => m.UpdatedAt);

            var listChatRoom = source.Select(m => new
            {
                m.ChatRoomId,
                userFriend = (m.User1.UserId == myUserId) ?
                 new
                 {
                     m.User2.UserName,
                     m.User2.ProfileImage
                 } :
                new
                {
                    m.User1.UserName,
                    m.User1.ProfileImage
                },
                userMeNewCount = (m.User1.UserId == myUserId) ? m.User1NewCount : m.User2NewCount,
                lastChatMessage = new
                {
                    message = (m.LastChatMessage == null) ? "" :
                        (m.LastChatMessage.User.UserId != myUserId && m.LastChatMessage.IsBlinded == true) ? BlindedChatMessage.Cut(20, "..") :
                        m.LastChatMessage.Message.Cut(20, ".."),
                    insertedAtDiff = (m.LastChatMessage == null) ? "" : GetDiff(m.LastChatMessage.InsertedAt),
                },
                relationshipScore = _context.RelationshipScoreFriend.Single(mm => mm.UserId1 == myUserId && mm.UserId2 == ((m.User1.UserId == myUserId) ? m.User2.UserId : m.User1.UserId)).ReferenceScore ?? -1,
            }).ToList();

            return Ok(new
            {
                listChatRoom
            });
        }
    }
}
