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
    [Route("/api/v{version:apiVersion}/article-comment/")]
    public class Api_1_0_ArticleCommentController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_ArticleCommentController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpPost("add")]
        public IActionResult Add([FromForm] int articleId, [FromForm] string comment)
        {
            var myUserId = User.FindFirstValue("myUserId");

            if (articleId == 0 || comment == null) return BadRequest();
            if (comment.Trim().Length < 2) return Ok(new { isSuccess = false, responseMessage = "댓글을 2글자 이상 입력해주세요" });

            var article = _context.Article.Include(m => m.User).SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return NotFound();

            article.CommentCount++;

            var userMe = _context.User.SingleOrDefault(m => m.UserId == myUserId);

            var articleComment = new ArticleComment
            {
                Article = article,
                User = userMe,
                Comment = comment.Trim(),
                RemoteIpAddress = HttpContext.Connection.RemoteIpAddress.ToString(),
                InsertedAt = DateTime.Now,
                UpdatedAt = DateTime.Now,
                IsDeleted = false,
                IsBlinded = false,
            };

            _context.Add(articleComment);

            if (userMe.UserId != article.User.UserId)
            {
                var pnContent = $"{userMe.UserName} 님이 회원님의 [{article.Subject}] 게시물에 댓글을 남겼습니다";
                var pn = new PersonalNotification
                {
                    Article = article,
                    FromUser = userMe,
                    ToUser = article.User,
                    NotificationType = "CM",
                    Content = pnContent,
                    InsertedAt = DateTime.Now,
                    HasChecked = false,
                };
                _context.Add(pn);
            }

            _context.SaveChanges();

            if (userMe.UserId != article.User.UserId)
            {
                SendPushNotification(_context, article.User.UserId, "NEW_COMMENT", $"[{article.Subject.Cut(7, "..")}] 게시물에 댓글이 추가되었습니다", userMe.UserName + " : " + comment.Cut(20, ".."));
            }

            return Ok(new { isSuccess = true, responseMessage = "" });
        }
    }
}
