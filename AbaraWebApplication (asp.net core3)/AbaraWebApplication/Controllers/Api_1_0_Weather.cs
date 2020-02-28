using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using System;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using System.Text.Json;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "User", AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/weather/")]
    public class Api_1_0_Weather : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_Weather(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("current")]
        public async Task<IActionResult> Current()
        {
            var remoteIpAddress = HttpContext.Connection.RemoteIpAddress.ToString();
            if (IsDebug) remoteIpAddress = "2001:19f0:7001:500e:5400:02ff:fe74:87c9";

            double lat, lon;

            {
                using var request = new HttpRequestMessage
                {
                    RequestUri = new Uri("http://ip-api.com/json/" + remoteIpAddress),
                    Method = HttpMethod.Get,
                };

                using var hc = new HttpClient();
                using var response = await hc.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var result = await response.Content.ReadAsStringAsync();
                Print(result);

                var jsonDoc = JsonDocument.Parse(result);
                var status = jsonDoc.RootElement.GetProperty("status").GetString();
                if (status != "success") return StatusCode(500);

                lat = jsonDoc.RootElement.GetProperty("lat").GetDouble();
                lon = jsonDoc.RootElement.GetProperty("lon").GetDouble();
                Print(lat);
                Print(lon);
            }

            string icon;
            string temperature;
            int weatherCode;

            {
                using var request = new HttpRequestMessage
                {
                    RequestUri = new Uri("http://api.openweathermap.org/data/2.5/weather?lat=" + lat + "&lon=" + lon + "&appid=" + OpenWeatherMapAppId),
                    Method = HttpMethod.Get
                };

                using var hc = new HttpClient();
                using var response = await hc.SendAsync(request);
                response.EnsureSuccessStatusCode();

                var result = await response.Content.ReadAsStringAsync();
                Print(result);

                var jsonDoc = JsonDocument.Parse(result);
                icon = "http://openweathermap.org/img/wn/" + jsonDoc.RootElement.GetProperty("weather")[0].GetProperty("icon").GetString() + "@2x.png";
                temperature = Math.Round(jsonDoc.RootElement.GetProperty("main").GetProperty("temp").GetDouble() - 273.15).ToString();
                weatherCode = jsonDoc.RootElement.GetProperty("weather")[0].GetProperty("id").GetInt32();
                if (temperature == "-0") temperature = "0";
                Print(icon);
                Print(temperature);
            }

            var weather = new Weather
            {
                Icon = icon,
                Temperature = temperature + "℃",
                CreatedAt = DateTime.Now,
            };

            var myUserId = User.FindFirstValue("myUserId");

            var wi = _context.WeatherInfo.SingleOrDefault(m => m.UserId == myUserId);
            if (wi == null)
            {
                wi = new WeatherInfo
                {
                    UserId = myUserId,
                    WeatherCode = weatherCode,
                };
                _context.Add(wi);
            }
            else
            {
                wi.WeatherCode = weatherCode;
            }
            _context.SaveChanges();

            return Ok(new { isSuccess = true, weather });
        }
    }
}
