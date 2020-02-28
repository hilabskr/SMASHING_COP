using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/")]
    public class Api_1_0_Controller : Controller
    {
        public Api_1_0_Controller()
        {
        }

        [HttpPost("check-version")]
        public IActionResult CheckVersion([FromForm] string appVersion)
        {
            var ver = new Version(appVersion);
            Print(ver);

            if (ver < new Version("0.9.10"))
            {
                return Ok(new { isUpdateNeeded = true, responseMessage = "최신버전 업데이트가 필요합니다" });
            }
            else if (ver < new Version("0.0.0"))
            {
                return Ok(new { isUpdateRecommended = true, responseMessage = "최신 버전이 나왔습니다!\n업데이트 하시겠어요?" });
            }
            else
            {
                return Ok(new { });
            }
        }
    }
}
