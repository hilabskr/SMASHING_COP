using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Mvc;
using System.Diagnostics;

namespace AbaraWebApplication.Controllers
{
    [ResponseCache(CacheProfileName = "Default")]
    public class ErrorController : Controller
    {
        [HttpGet("/error")]
        [HttpPost("/error")]
        public IActionResult Error()
        {
            return View();
        }
    }
}
