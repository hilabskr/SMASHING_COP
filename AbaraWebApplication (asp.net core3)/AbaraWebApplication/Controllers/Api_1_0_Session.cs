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
    [Route("/api/v{version:apiVersion}/session/")]
    public class Api_1_0_SessionController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_SessionController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpPost("update")]
        public void Update([FromForm] string firebaseToken, [FromForm] string appVersion, [FromForm] string platformType, [FromForm] string platformVersion)
        {
            var mySessionId = Convert.ToInt64(User.FindFirstValue("mySessionId"));

            var session = _context.Session.SingleOrDefault(m => m.SessionId == mySessionId);
            if (session != null)
            {
                try
                {
                    if (string.IsNullOrEmpty(firebaseToken) == false)
                    {
                        session.FirebaseToken = firebaseToken;

                        var list = _context.Session.Where(m => m.SessionId != mySessionId && m.FirebaseToken == firebaseToken);

                        foreach (var sessionToUpdate in list)
                        {
                            Print(sessionToUpdate.SessionId + " FirebaseToken 삭제");
                            sessionToUpdate.FirebaseToken = null;
                            sessionToUpdate.UpdatedAt = DateTime.Now;
                            sessionToUpdate.IsExpired = true;
                        }
                    }
                    session.AppVersion = appVersion;
                    session.PlatformType = platformType;
                    session.PlatformVersion = platformVersion;
                    session.RemoteIpAddress = HttpContext.Connection.RemoteIpAddress.ToString();
                    session.UpdatedAt = DateTime.Now;
                    session.IsExpired = false;
                    _context.SaveChanges();
                }
                catch { }
            }
        }

        [HttpPost("logout")]
        public void Logout()
        {
            var mySessionId = Convert.ToInt64(User.FindFirstValue("mySessionId"));

            var session = _context.Session.SingleOrDefault(m => m.SessionId == mySessionId);
            if (session != null)
            {
                session.FirebaseToken = null;
                session.RemoteIpAddress = HttpContext.Connection.RemoteIpAddress.ToString();
                session.UpdatedAt = DateTime.Now;
                session.IsExpired = true;
                _context.SaveChanges();
            }
        }
    }
}
