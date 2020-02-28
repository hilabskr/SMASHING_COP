using AbaraWebApplication.Data;
using AbaraWebApplication.Extras;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Linq;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "Admin", AuthenticationSchemes = CookieAuthenticationDefaults.AuthenticationScheme)]
    [Route("/admin/relationship-score/")]
    [ResponseCache(CacheProfileName = "NoStore")]
    public class Admin_RelationshipScoreController : Controller
    {
        private readonly WebApplicationContext _context;

        public Admin_RelationshipScoreController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("list1")]
        public IActionResult List1(int page = 1)
        {
            var pageIndex = page;
            var pageSize = 30;
            var pageLinkCount = 10;

            var source = from R in _context.RelationshipScoreArticleFree.AsNoTracking()
                         orderby R.UpdatedAt descending
                         select R;

            return View(new PaginatedList<RelationshipScoreArticleFree>(source, pageIndex, pageSize, pageLinkCount));
        }

        [HttpGet("list2")]
        public IActionResult List2(int page = 1)
        {
            var pageIndex = page;
            var pageSize = 30;
            var pageLinkCount = 10;

            var source = from R in _context.RelationshipScoreArticleMarket.AsNoTracking()
                         orderby R.UpdatedAt descending
                         select R;

            return View(new PaginatedList<RelationshipScoreArticleMarket>(source, pageIndex, pageSize, pageLinkCount));
        }

        [HttpGet("list3")]
        public IActionResult List3(int page = 1)
        {
            var pageIndex = page;
            var pageSize = 30;
            var pageLinkCount = 10;

            var source = from R in _context.RelationshipScoreFriend.AsNoTracking()
                         orderby R.UpdatedAt descending
                         select R;

            return View(new PaginatedList<RelationshipScoreFriend>(source, pageIndex, pageSize, pageLinkCount));
        }
    }
}
