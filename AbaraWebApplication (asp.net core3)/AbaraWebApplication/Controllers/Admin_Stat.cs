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
    [Route("/admin/stat/")]
    [ResponseCache(CacheProfileName = "NoStore")]
    public class Admin_StatController : Controller
    {
        private readonly WebApplicationContext _context;

        public Admin_StatController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("")]
        public IActionResult Default()
        {
            return RedirectToAction(nameof(Index));
        }

        [HttpGet("index")]
        public IActionResult Index()
        {
            return View();
        }
    }
}
