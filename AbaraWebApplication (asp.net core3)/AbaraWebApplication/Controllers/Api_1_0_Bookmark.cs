using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using System.Security.Claims;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "User", AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/bookmark/")]
    public class Api_1_0_BookmarkController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_BookmarkController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("list")]
        public IActionResult List()
        {
            var myUserId = User.FindFirstValue("myUserId");

            var listBookmark = (from B in _context.Bookmark.AsNoTracking()
                                where B.User.UserId == myUserId
                                orderby B.BookmarkId descending
                                select new
                                {
                                    B.BookmarkId,
                                    article = new
                                    {
                                        B.Article.ArticleId,
                                        subject = B.Article.Subject.Cut(20, ".."),
                                        content = B.Article.Content.Cut(30, ".."),
                                        B.Article.CoverImage,
                                        insertedAtDiff = GetDiff(B.Article.InsertedAt),
                                    },
                                }).ToList();

            return Ok(new
            {
                listBookmark
            });
        }

        [HttpPost("add")]
        public IActionResult Add([FromForm] int articleId)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var article = _context.Article.SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return NotFound();

            if (_context.Bookmark.AsNoTracking().FirstOrDefault(m => m.Article.ArticleId == article.ArticleId && m.User.UserId == myUserId) != null)
            {
                return Ok(new { isToggled = true, responseMessage = "이미 북마크에 추가된 항목입니다" });
            }

            var bookmark = new Bookmark
            {
                Article = article,
                User = _context.User.SingleOrDefault(m => m.UserId == myUserId),
                InsertedAt = DateTime.Now,
            };

            _context.Bookmark.Add(bookmark);
            _context.SaveChanges();

            return Ok(new { isToggled = true, responseMessage = "북마크에 추가되었습니다" });
        }

        [HttpPost("remove")]
        public IActionResult Remove([FromForm] int articleId)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var article = _context.Article.AsNoTracking().SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return NotFound();

            var bookmark = _context.Bookmark.AsNoTracking().FirstOrDefault(m => m.Article.ArticleId == article.ArticleId && m.User.UserId == myUserId);
            if (bookmark == null)
            {
                return Ok(new { isToggled = false, responseMessage = "이미 북마크에서 삭제된 항목입니다" });
            }

            _context.Remove(bookmark);
            _context.SaveChanges();

            return Ok(new { isToggled = false, responseMessage = "북마크에서 삭제되었습니다" });
        }
    }
}
