using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using System;
using System.Collections.Generic;
using System.IO;
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
    [Route("/api/v{version:apiVersion}/article/")]
    public class Api_1_0_ArticleController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_ArticleController(WebApplicationContext context)
        {
            _context = context;
        }

        [HttpGet("list")]
        [HttpGet("{category1}/list")]
        [HttpGet("{category1}/{category2}/list")]
        public async Task<IActionResult> List(string category1, string category2, string userId, int? after)
        {
            var myUserId = User.FindFirstValue("myUserId");

            if (IsDebug) await Task.Delay(500);

            var source = _context.Article.Include(m => m.User).AsNoTracking();

            if (userId != null)
            {
                if (userId.Length != 6) return BadRequest();
                if (userId == myUserId)
                {
                    source = source.Where(m => m.User.UserId == userId);
                }
                else
                {
                    source = source.Where(m => m.User.UserId == userId && m.Category1 != "FR");
                }
            }

            if (category1 != null)
            {
                if (DicUrlCategory1.ContainsKey(category1) == false) return BadRequest();
                if (DicUrlCategory1[category1] == "FR" && userId != null && userId != myUserId) return BadRequest();
                source = source.Where(m => m.Category1 == DicUrlCategory1[category1]);
            }
            if (category2 != null) source = source.Where(m => m.Category2 == category2);

            if (after != null) source = source.Where(m => m.ArticleId < after);

            source = source.Where(m => m.IsDeleted == false && m.IsBlinded == false);

            var pageSize = 10;
            var listArticle = source.OrderByDescending(m => m.ArticleId).Take(pageSize).Select(m => new
            {
                m.ArticleId,
                user = (m.Category1 == "FR") ? null /*익명*/ : new
                {
                    m.User.UserName,
                },
                m.Subject,
                m.CoverImage,
                content = m.Content.Cut(60, ".."),
                m.UpvoteProfileImages,
                m.UpvoteCount,
                relationshipScore =
                (userId != myUserId && category1 != null && DicUrlCategory1[category1] == "FR") ? _context.RelationshipScoreArticleFree.Single(mm => mm.UserId == myUserId && mm.ArticleId == m.ArticleId).RelationshipScore ?? -1 :
                (userId != myUserId && category1 != null && DicUrlCategory1[category1] == "MK") ? _context.RelationshipScoreArticleMarket.Single(mm => mm.UserId == myUserId && mm.ArticleId == m.ArticleId).RelationshipScore ?? -1 :
                -1,
            }).ToList();

            return Ok(new
            {
                listArticle
            });
        }

        [HttpGet("details/{articleId}")]
        public IActionResult Details(int articleId)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var article = _context.Article.Include(m => m.User).SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return Ok(new { isSuccess = false, responseMessage = "해당되는 게시물이 없습니다" });
            if (article.IsDeleted) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.IsBlinded) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });

            if (article.ViewUserIds.IndexOf(myUserId) == -1)
            {
                article.ViewUserIds = (article.ViewUserIds == "") ? myUserId : article.ViewUserIds + "," + myUserId;
                article.ViewCount++;
                _context.SaveChanges();
            }

            var isBookmarked = (_context.Bookmark.AsNoTracking().SingleOrDefault(m => m.Article.ArticleId == article.ArticleId && m.User.UserId == myUserId) != null);

            var listArticleComment = (from AC in _context.ArticleComment.AsNoTracking()
                                      where AC.Article.ArticleId == article.ArticleId && AC.IsDeleted == false && AC.IsBlinded == false
                                      orderby AC.ArticleCommentId
                                      select new
                                      {
                                          user = (article.Category1 == "FR" && AC.User.UserId == article.User.UserId) ? null /*익명*/ : new
                                          {
                                              AC.User.UserId,
                                              AC.User.UserName,
                                              AC.User.SchoolName,
                                              AC.User.ProfileImage,
                                          },
                                          AC.Comment,
                                          insertedAtDiff = GetDiff(AC.InsertedAt),
                                      }).ToList();

            return Ok(new
            {
                article = new
                {
                    article.ArticleId,
                    user = (article.Category1 == "FR") ? null /*익명*/ : new
                    {
                        article.User.UserId,
                        article.User.UserName,
                        article.User.SchoolName,
                        article.User.ProfileImage,
                    },
                    article.Category1,
                    article.Category2,
                    article.Subject,
                    article.FileNames,
                    article.FileProperties,
                    article.Content,
                    article.UpvoteCount,
                    article.CommentCount,
                    insertedAtDiff = GetDiff(article.InsertedAt),
                    isEditable = (article.User.UserId == myUserId),
                    isUpvoted = (article.UpvoteUserIds.IndexOf(myUserId) != -1),
                    isBookmarked,
                },
                listArticleComment,
            });
        }

        [HttpPost("{category1}/add")]
        [HttpPost("{category1}/{category2}/add")]
        [RequestSizeLimit(50_000_000)]
        public async Task<IActionResult> Add(string category1, string category2, [FromForm] string subject, [FromForm] string content, IFormFile file0, IFormFile file1, IFormFile file2, IFormFile file3)
        {
            var myUserId = User.FindFirstValue("myUserId");
            var myEmail = User.FindFirstValue("myEmail");

            if (category1 == null || DicUrlCategory1.ContainsKey(category1) == false) return BadRequest();
            category1 = DicUrlCategory1[category1];

            if (category1 == "MK" && category2 == null) return BadRequest();
            if (category1 == "JB" && category2 == null) category2 = "구직";

            if (subject == null || content == null) return BadRequest();
            if (subject.Trim().Length < 2) return Ok(new { isSuccess = false, responseMessage = "제목을 2자 이상 입력해주세요" });
            if (subject.Trim().Length > 50) return Ok(new { isSuccess = false, responseMessage = "제목을 50자 이하로 입력해주세요" });
            if (content.Trim().Length < 10) return Ok(new { isSuccess = false, responseMessage = "내용을 10자 이상 입력해주세요" });

            var listFile = new List<IFormFile>
            {
                file0,  file1,  file2,  file3
            };

            var listFileName = new List<string>();
            var listFileProperty = new List<string>();
            string coverImage = null;

            var listToDeleteOnException = new List<string>();

            try
            {
                for (int i = 0; i < 4; i++)
                {
                    listFileName.Add("_");
                    listFileProperty.Add("_");

                    Print("listFile[" + i + "] == null " + (listFile[i] == null));

                    if (listFile[i]?.Length > 0)
                    {
                        PrintIFormFile(listFile[i]);

                        EnsurePngOrJpeg(listFile[i].FileName);

                        var newPath1 = "";
                        do
                        {
                            newPath1 = GetImagePath("article", GenerateNewFileName(listFile[i].FileName));

                        } while (System.IO.File.Exists(newPath1));

                        using (var fs = new FileStream(newPath1, FileMode.CreateNew))
                        {
                            await listFile[i].CopyToAsync(fs);
                        }
                        listToDeleteOnException.Add(newPath1);

                        using (var image = Image.Load(newPath1))
                        {
                            image.Mutate(x => x.AutoOrient());
                            image.Metadata.ExifProfile = null;
                            image.Save(newPath1);
                        }

                        var newPath2 = GetImagePath("article-resized", Path.GetFileName(newPath1));

                        using (var image = Image.Load(newPath1))
                        {
                            listFileName[i] = Path.GetFileName(newPath1);
                            listFileProperty[i] = image.Width + "x" + image.Height;

                            var w = 340 * 3;
                            image.Mutate(x => x.Resize(w, image.Height * w / image.Width));
                            image.Save(newPath2);
                        }
                        listToDeleteOnException.Add(newPath2);

                        if (coverImage == null) coverImage = Path.GetFileName(newPath2);
                    }
                }
            }
            catch (Exception)
            {
                await DeleteFiles(listToDeleteOnException);

                return Ok(new { isSuccess = false, responseMessage = "파일 처리 중 에러가 발생하였습니다" });
            }

            var insertedAt = DateTime.Now;
            var updatedAt = DateTime.Now;

            try
            {
                var article = new Article
                {
                    User = _context.User.SingleOrDefault(m => m.UserId == myUserId),
                    Category1 = category1,
                    Category2 = category2,
                    Subject = subject.Trim(),
                    FileNames = string.Join("/", listFileName),
                    FileProperties = string.Join("/", listFileProperty),
                    CoverImage = coverImage,
                    Content = content.Trim(),
                    ViewUserIds = "",
                    ViewCount = 0,
                    CommentCount = 0,
                    UpvoteUserIds = "",
                    UpvoteProfileImages = "",
                    UpvoteCount = 0,
                    RemoteIpAddress = HttpContext.Connection.RemoteIpAddress.ToString(),
                    InsertedAt = insertedAt,
                    UpdatedAt = updatedAt,
                    IsOngoing = true,
                    IsDeleted = false,
                    IsBlinded = false,
                };
                _context.Add(article);
                if (_context.SaveChanges() != 1) throw new Exception();
            }
            catch (Exception ex)
            {
                Print(ex);
                await DeleteFiles(listToDeleteOnException);

                return Ok(new { isSuccess = false, responseMessage = "저장 중 에러가 발생하였습니다" });
            }

            return Ok(new { isSuccess = true, responseMessage = "성공적으로 입력되었습니다" });
        }

        [HttpPost("edit/{articleId}")]
        public IActionResult Edit(int articleId, [FromForm] string subject, [FromForm] string content)
        {
            var myUserId = User.FindFirstValue("myUserId");

            if (subject == null || content == null) return BadRequest();
            if (subject.Trim().Length < 2) return Ok(new { isSuccess = false, responseMessage = "제목을 2자 이상 입력해주세요" });
            if (subject.Trim().Length > 50) return Ok(new { isSuccess = false, responseMessage = "제목을 50자 이하로 입력해주세요" });
            if (content.Trim().Length < 10) return Ok(new { isSuccess = false, responseMessage = "내용을 10자 이상 입력해주세요" });

            var article = _context.Article.Include(m => m.User).SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return Ok(new { isSuccess = false, responseMessage = "해당되는 게시물이 없습니다" });
            if (article.IsDeleted) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.IsBlinded) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.User.UserId != myUserId) return Ok(new { isSuccess = false, responseMessage = "권한이 없습니다" });

            article.Subject = subject.Trim();
            article.Content = content.Trim();
            article.UpdatedAt = DateTime.Now;
            _context.SaveChanges();

            return Ok(new { isSuccess = true, responseMessage = "성공적으로 수정되었습니다" });
        }

        [HttpPost("delete/{articleId}")]
        public IActionResult Delete(int articleId)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var article = _context.Article.Include(m => m.User).SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return Ok(new { isSuccess = false, responseMessage = "해당되는 게시물이 없습니다" });
            if (article.IsDeleted) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.IsBlinded) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.User.UserId != myUserId) return Ok(new { isSuccess = false, responseMessage = "권한이 없습니다" });

            article.IsDeleted = true;
            article.UpdatedAt = DateTime.Now;
            _context.SaveChanges();

            return Ok(new { isSuccess = true, responseMessage = "삭제되었습니다" });
        }

        [HttpPost("upvote/{articleId}")]
        public IActionResult Upvote(int articleId)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var article = _context.Article.Include(m => m.User).SingleOrDefault(m => m.ArticleId == articleId);
            if (article == null) return Ok(new { isSuccess = false, responseMessage = "해당되는 게시물이 없습니다" });
            if (article.IsDeleted) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });
            if (article.IsBlinded) return Ok(new { isSuccess = false, responseMessage = "삭제된 게시물입니다" });

            if (myUserId == article.User.UserId)
            {
                return Ok(new { isSuccess = false, responseMessage = "본인의 글에는 좋아요를 할 수 없습니다" });
            }
            else if (article.UpvoteUserIds.IndexOf(myUserId) == -1)
            {
                article.UpvoteUserIds = (article.UpvoteUserIds == "") ? myUserId : article.UpvoteUserIds + "," + myUserId;

                var userMe = _context.User.SingleOrDefault(m => m.UserId == myUserId);
                var myProfileImage = userMe.ProfileImage;
                if (string.IsNullOrEmpty(myProfileImage)) myProfileImage = "_";

                if (string.IsNullOrEmpty(article.UpvoteProfileImages))
                {
                    article.UpvoteProfileImages = myProfileImage;
                }
                else
                {
                    var list = article.UpvoteProfileImages.Split(',').ToList();
                    if (list.Count == 1 || list.Count == 2)
                    {
                        article.UpvoteProfileImages = article.UpvoteProfileImages + "," + myProfileImage;
                    }
                    else
                    {
                        article.UpvoteProfileImages = list[list.Count - 2] + "," + list[list.Count - 1] + "," + myProfileImage;
                    }
                }

                article.UpvoteCount++;

                var pnContent = $"{userMe.UserName} 님이 회원님의 [{article.Subject}] 게시물을 좋아합니다";
                var pn = new PersonalNotification
                {
                    Article = article,
                    FromUser = userMe,
                    ToUser = article.User,
                    NotificationType = "UV",
                    Content = pnContent,
                    InsertedAt = DateTime.Now,
                    HasChecked = false,
                };
                _context.Add(pn);

                _context.SaveChanges();

                return Ok(new { isSuccess = true });
            }
            else
            {
                return Ok(new { isSuccess = false });
            }
        }
    }
}
