using AbaraWebApplication.Data;
using AbaraWebApplication.Extras;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
using System.Linq;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "Admin", AuthenticationSchemes = CookieAuthenticationDefaults.AuthenticationScheme)]
    [Route("/admin/article/")]
    [ResponseCache(CacheProfileName = "NoStore")]
    public class Admin_ArticleController : Controller
    {
        private readonly WebApplicationContext _context;

        public Admin_ArticleController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("{category1}/list")]
        public IActionResult List(string category1, int page = 1)
        {
            if (category1 == null || DicUrlCategory1.ContainsKey(category1) == false) return BadRequest();
            category1 = DicUrlCategory1[category1];

            ViewBag.Category1 = category1;

            var pageIndex = page;
            var pageSize = 30;
            var pageLinkCount = 10;

            var source = from A in _context.Article.Include(m => m.User).AsNoTracking()
                         where A.Category1 == category1
                         orderby A.ArticleId descending
                         select A;

            return View(new PaginatedList<Article>(source, pageIndex, pageSize, pageLinkCount));
        }

        [HttpGet("details/{articleId}")]
        [HttpGet("{category1}/details/{articleId}")]
        [HttpGet("{category1}/{category2}/details/{articleId}")]
        public IActionResult Details(int articleId)
        {
            var article = _context.Article.Include(m => m.User).AsNoTracking().SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null)
            {
                ViewBag.ErrorMessage = "해당되는 게시물이 없습니다";
                return View();
            }

            return View(article);
        }

        [HttpPost("edit/{articleId}")]
        public IActionResult Edit(int articleId, bool isDeleted)
        {
            Print(isDeleted);

            var article = _context.Article.SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return NotFound();

            article.IsDeleted = isDeleted;
            _context.SaveChanges();

            return Redirect("/admin/article/" + DicCategory1Url[article.Category1] + "/list");
        }
    }
}
