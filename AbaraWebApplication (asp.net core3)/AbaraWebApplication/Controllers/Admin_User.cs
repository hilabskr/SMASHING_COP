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
    [Route("/admin/user/")]
    [ResponseCache(CacheProfileName = "NoStore")]
    public class Admin_UserController : Controller
    {
        private readonly WebApplicationContext _context;

        public Admin_UserController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("")]
        public IActionResult Default()
        {
            return RedirectToAction(nameof(List));
        }

        [HttpGet("list")]
        public IActionResult List(int page = 1)
        {
            var pageIndex = page;
            var pageSize = 30;
            var pageLinkCount = 10;

            var source = from U in _context.User.AsNoTracking()
                         orderby U.SignUpAt descending
                         select U;

            return View(new PaginatedList<User>(source, pageIndex, pageSize, pageLinkCount));
        }

        [HttpGet("details/{userId}")]
        public IActionResult Details(string userId)
        {
            var user = _context.User.AsNoTracking().SingleOrDefault(m => m.UserId == userId);
            if (user == null)
            {
                ViewBag.ErrorMessage = "해당되는 회원이 없습니다";
                return View();
            }

            return View(user);
        }
    }
}
