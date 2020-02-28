using Microsoft.AspNetCore.Mvc;
using System.IO;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [ResponseCache(CacheProfileName = "Cache")]
    public class ImageController : Controller
    {
        [HttpGet("/image/{category}/{fileName}")]
        public async Task<IActionResult> Image(string category, string fileName)
        {
            if (fileName.EndsWith(".jpg") == false && fileName.EndsWith(".png") == false) return NotFound();

            var path = GetImagePath(category, fileName);
            if (System.IO.File.Exists(path) == false) return NotFound();

            var ms = new MemoryStream();
            using (var fs = new FileStream(path, FileMode.Open))
            {
                await fs.CopyToAsync(ms);
            }
            ms.Position = 0;

            return File(ms, fileName.EndsWith(".png") ? "image/png" : "image/jpeg");
        }
    }
}
