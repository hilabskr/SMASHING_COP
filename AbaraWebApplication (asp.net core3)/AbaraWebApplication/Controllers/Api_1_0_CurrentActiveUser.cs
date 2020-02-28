using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
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
    [Route("/api/v{version:apiVersion}/current-active-user/")]
    public class Api_1_0_CurrentActiveUserController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_CurrentActiveUserController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpPost("update")]
        public void Update()
        {
            var myUserId = User.FindFirstValue("myUserId");

            var cau = _context.CurrentActiveUser.SingleOrDefault(m => m.UserId == myUserId);
            if (cau == null)
            {
                cau = new CurrentActiveUser
                {
                    UserId = myUserId,
                    IsActive = true,
                    UpdatedAt = DateTime.Now,
                };
                _context.Add(cau);
            }
            else
            {
                cau.IsActive = true;
                cau.UpdatedAt = DateTime.Now;
            }
            _context.SaveChanges();
        }
    }
}
