using AbaraWebApplication.Data;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Security.Claims;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Route("/admin")]
    [ResponseCache(CacheProfileName = "NoStore")]
    public class AdminController : Controller
    {
        private readonly WebApplicationContext _context;

        public AdminController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("")]
        public IActionResult Default()
        {
            return NotFound();
        }

        [HttpGet("login")]
        public IActionResult Login()
        {
            var remoteIpAddress4 = HttpContext.Connection.RemoteIpAddress.MapToIPv4().ToString();

            ViewBag.RemoteIpAddress4 = remoteIpAddress4;

            return View();
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(string adminId, string adminPassword, string isPersistent)
        {
            var remoteIpAddress4 = HttpContext.Connection.RemoteIpAddress.MapToIPv4().ToString();

            if (adminPassword != AdminPassword)
            {
                await Task.Delay(2000);
                return Ok("관리자 암호가 일치하지 않습니다");
            }

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Role, "Admin"),
            };
            var ci = new ClaimsIdentity(claims, CookieAuthenticationDefaults.AuthenticationScheme);
            var ap = new AuthenticationProperties()
            {
            };

            if (isPersistent == "on")
            {
                ap.IsPersistent = true;
                ap.ExpiresUtc = DateTime.UtcNow.AddDays(30);
            }

            await HttpContext.SignInAsync(CookieAuthenticationDefaults.AuthenticationScheme, new ClaimsPrincipal(ci), ap);

            return Redirect("user");
        }

        [Authorize(Roles = "Admin", AuthenticationSchemes = CookieAuthenticationDefaults.AuthenticationScheme)]
        [HttpGet("blank")]
        public IActionResult Blank()
        {
            return View();
        }

        [Authorize(Roles = "Admin", AuthenticationSchemes = CookieAuthenticationDefaults.AuthenticationScheme)]
        [HttpGet("logout")]
        public async Task<IActionResult> Logout()
        {
            await HttpContext.SignOutAsync(CookieAuthenticationDefaults.AuthenticationScheme);

            return View();
        }
    }
}
