using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System;
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
    [Route("/api/v{version:apiVersion}/personal-notification/")]
    public class Api_1_0_PersonalNotificationController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_PersonalNotificationController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("list")]
        public async Task<IActionResult> List(int? after)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var source = _context.PersonalNotification.Include(m => m.Article).Include(m => m.FromUser).Include(m => m.ToUser).Where(m => m.ToUser.UserId == myUserId);

            if (after != null) source = source.Where(m => m.PersonalNotificationId < after);

            var pageSize = 20;

            if (IsDebug)
            {
                await Task.Delay(1000);
                pageSize = 2;
            }

            source = source.OrderByDescending(m => m.PersonalNotificationId).Take(pageSize);

            var listPersonalNotification = source.Select(m => new
            {
                m.PersonalNotificationId,
                article = new { m.Article.ArticleId },
                fromUser = new { m.FromUser.ProfileImage },
                m.Content,
                insertedAtDiff = GetDiff(m.InsertedAt),
                m.HasChecked,
            }).ToList();

            foreach (var pn in source)
            {
                if (pn.HasChecked == false)
                {
                    pn.HasChecked = true;
                    pn.CheckedAt = DateTime.Now;
                }
            }
            _context.SaveChanges();

            return Ok(new
            {
                listPersonalNotification
            });
        }
    }
}
