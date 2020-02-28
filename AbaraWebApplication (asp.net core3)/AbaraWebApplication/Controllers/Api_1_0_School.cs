using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Mvc;
using NPOI.SS.UserModel;
using NPOI.XSSF.UserModel;
using System;
using System.Linq;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/school/")]
    public class Api_1_0_SchoolController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_SchoolController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("update")]
        public async Task<IActionResult> Update()
        {
            if (IsDebug == false) return BadRequest();

            try
            {
                _context.RemoveRange(_context.School);

                XSSFWorkbook xssfwb = new XSSFWorkbook(@"C:\Users\w10\Desktop\2. 고등교육기관 주소록(2019) 전국대학리스트.xlsx");
                ISheet sheet = xssfwb.GetSheetAt(0);

                Print(sheet.FirstRowNum);
                Print(sheet.LastRowNum);

                for (int i = 6; i <= sheet.LastRowNum; i++)
                {
                    IRow row = sheet.GetRow(i);

                    Print("--- " + i);

                    if (row.GetCell(6)?.StringCellValue.Trim() == "기존" &&
                        string.IsNullOrWhiteSpace(row.GetCell(12)?.StringCellValue) == false)
                    {
                        Print(row.GetCell(3)?.StringCellValue + " " + row.GetCell(12)?.StringCellValue);

                        var school = new School
                        {
                            SchoolId = row.GetCell(3)?.StringCellValue + " " + row.GetCell(5)?.StringCellValue,
                            SchoolName = row.GetCell(3)?.StringCellValue,
                            Domain = row.GetCell(12).StringCellValue.Replace("http://", "").Replace("https://", ""),
                            InsertedAt = DateTime.Now,
                        };

                        _context.Add(school);
                    }
                }

                _context.Add(new School
                {
                    SchoolId = "하이랩스",
                    SchoolName = "차의과학대학교",
                    Domain = "hilabs.co.kr",
                    InsertedAt = DateTime.Now,
                });

                await _context.SaveChangesAsync();

                return Ok(_context.School.Count());
            }
            catch (Exception ex)
            {
                Print(ex);

                return Ok(ex.Message);
            }
        }
    }
}
