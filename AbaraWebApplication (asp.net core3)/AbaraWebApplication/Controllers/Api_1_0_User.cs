using AbaraWebApplication.Data;
using AbaraWebApplication.Models;
using MailKit.Net.Smtp;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using MimeKit;
using SixLabors.ImageSharp;
using SixLabors.ImageSharp.Processing;
using System;
using System.Collections.Generic;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication.Controllers
{
    [Authorize(Roles = "User", AuthenticationSchemes = JwtBearerDefaults.AuthenticationScheme)]
    [ApiController]
    [ApiVersion("1.0")]
    [Produces("application/json")]
    [Route("/api/v{version:apiVersion}/user/")]
    public class Api_1_0_UserController : Controller
    {
        private readonly WebApplicationContext _context;

        public Api_1_0_UserController(WebApplicationContext context)
        {
            _context = context;
        }

        [AllowAnonymous]
        [HttpPost("sign-up")]
        public IActionResult SignUp([FromForm] string userName, [FromForm] string email, [FromForm] string newPassword, [FromForm] string gender, [FromForm] int birthYear)
        {

            if (string.IsNullOrWhiteSpace(userName))
            {
                return Ok(new { isSuccess = false, responseMessage = "이름을 입력해주세요" });
            }
            if (userName.Trim().Length < 2)
            {
                return Ok(new { isSuccess = false, responseMessage = "이름을 2자 이상 입력해주세요" });
            }
            if (userName.Trim().Length > 20)
            {
                return Ok(new { isSuccess = false, responseMessage = "이름을 20자 이하로 입력해주세요" });
            }

            if (string.IsNullOrWhiteSpace(email))
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 입력해주세요" });
            }
            if (IsValidEmail(email) == false)
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 형식을 확인해주세요" });
            }

            if (string.IsNullOrWhiteSpace(newPassword))
            {
                return Ok(new { isSuccess = false, responseMessage = "새로운 암호를 입력해주세요" });
            }
            if (newPassword.Length < 4)
            {
                return Ok(new { isSuccess = false, responseMessage = "새로운 암호를 4자 이상 입력해주세요" });
            }

            if (string.IsNullOrWhiteSpace(gender))
            {
                gender = "N";
            }
            else if (gender != "M" && gender != "F")
            {
                return BadRequest();
            }

            if (birthYear == 0)
            {
            }
            else if (birthYear < DateTime.Now.Year - 100 || birthYear > DateTime.Now.Year)
            {
                return BadRequest();
            }

            email = email.Trim().ToLower();
            if (_context.User.AsNoTracking().SingleOrDefault(m => m.Email == email) != null)
            {
                return Ok(new { isSuccess = false, responseMessage = $"{email} 은 이미 등록된 메일주소입니다" });
            }

            var domainOfEmail = email.Substring(email.IndexOf("@") + 1);
            Print(domainOfEmail);

            var schoolName = _context.School.AsNoTracking().FirstOrDefault(m => m.Domain.IndexOf(domainOfEmail) != -1)?.SchoolName;
            if (schoolName == null)
            {
                return Ok(new { isSuccess = false, responseMessage = $"{domainOfEmail} 에 해당되는 학교명이 없습니다" });
            }

            var salt = GenerateSalt();
            var hashedPassword = HashPassword(salt, newPassword);

            var verificationCode = "";
            do
            {
                verificationCode = new Random().Next(1000, 10000).ToString();

            } while (verificationCode[0] == verificationCode[1] || verificationCode[0] == 6 || verificationCode[1] == 6 || verificationCode[2] == 6 || verificationCode.IndexOf("1" + "8") >= 0);

            var userVerification = new UserVerification
            {
                UserName = userName.Trim(),
                Email = email,
                SchoolName = schoolName,
                Salt = salt,
                HashedPassword = hashedPassword,
                Gender = gender,
                BirthYear = birthYear,
                VerificationCode = verificationCode,
                CreatedAt = DateTime.Now,
                FailCount = 0,
                HasSuccess = false,
            };

            _context.Add(userVerification);
            _context.SaveChanges();

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("아바라", "contact@hilabs.co.kr"));
            message.To.Add(new MailboxAddress(userName, email));
            message.Subject = "아바라 회원가입 - 보안코드입니다";

            var bb = new BodyBuilder();
            bb.TextBody = $"보안코드는 {verificationCode} 입니다";
            message.Body = bb.ToMessageBody();

            if (IsRelease)
            {
                using var client = new SmtpClient();
                client.Connect("127.0.0.1", 25, false);
                client.Send(message);
                client.Disconnect(true);
            }

            return Ok(new
            {
                isSuccess = true,
                responseMessage = $"{email} 로\n보안코드가 발송되었습니다 (유효 {VerificationCodeExpireHour}시간)",
                userVerification = new { userVerification.UserVerificationId },
            });
        }

        [AllowAnonymous]
        [HttpPost("check-verification-code/{userVerificationId}")]
        public IActionResult UserVerification(long userVerificationId, [FromForm] string verificationCode)
        {
            if (userVerificationId == 0) return BadRequest();

            if (verificationCode == null || verificationCode.Trim().Length != 4)
            {
                return Ok(new { isSuccess = false, responseMessage = "보안코드 4자리를 입력해주세요" });
            }

            var userVerification = _context.UserVerification.SingleOrDefault(m => m.UserVerificationId == userVerificationId);

            if (userVerification == null || userVerification.HasSuccess)
            {
                return Ok(new { isSuccess = false, responseMessage = "잘못된 요청입니다" });
            }

            if (userVerification.FailCount >= VerificationCodeMaxFailCount)
            {
                return Ok(new { isSuccess = false, responseMessage = $"{VerificationCodeMaxFailCount}회 잘못 입력되었습니다\n\n이전 페이지로 돌아가서\n다시 진행해주세요" });
            }

            if (userVerification.CreatedAt < DateTime.Now.AddHours(-VerificationCodeExpireHour))
            {
                return Ok(new { isSuccess = false, responseMessage = $"보안코드 유효 {VerificationCodeExpireHour}시간이 지났습니다\n\n이전 페이지로 돌아가서\n다시 진행해주세요" });
            }

            if (userVerification.VerificationCode != verificationCode.Trim())
            {
                userVerification.FailCount++;
                _context.SaveChanges();

                if (userVerification.FailCount >= VerificationCodeMaxFailCount)
                {
                    return Ok(new { isSuccess = false, responseMessage = $"{VerificationCodeMaxFailCount}회 잘못 입력되었습니다\n\n이전 페이지로 돌아가서\n다시 진행해주세요" });
                }
                else
                {
                    return Ok(new { isSuccess = false, responseMessage = "보안코드가 일치하지 않습니다" });
                }
            }

            var userId = "";
            var count = 0;
            do
            {
                userId = GenerateRandom20(6);
                if (count++ > 10) throw new Exception();

            } while (_context.User.AsNoTracking().SingleOrDefault(m => m.UserId == userId) != null);

            var user = new User
            {
                UserId = userId,
                UserName = userVerification.UserName,
                Email = userVerification.Email,
                SchoolName = userVerification.SchoolName,
                Salt = userVerification.Salt,
                HashedPassword = userVerification.HashedPassword,
                Gender = userVerification.Gender,
                BirthYear = userVerification.BirthYear,
                SignUpAt = DateTime.Now,
                UpdatedAt = DateTime.Now,
                AllowOthersToFindMe = true,
            };

            userVerification.HasSuccess = true;
            _context.Add(user);
            _context.SaveChanges();

            return Ok(new { isSuccess = true, responseMessage = "성공적으로 등록되었습니다\n\n로그인 페이지로 이동합니다" });
        }

        [AllowAnonymous]
        [HttpPost("reset-password")]
        public IActionResult ResetPassword([FromForm] string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 입력해주세요" });
            }
            if (IsValidEmail(email) == false)
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 형식을 확인해주세요" });
            }

            var user = _context.User.SingleOrDefault(m => m.Email == email);
            if (user == null)
            {
                return Ok(new { isSuccess = false, responseMessage = "등록된 이메일이 아닙니다" });
            }

            var salt = GenerateSalt();
            var newPassword = GenerateRandom20(6);
            var hashedPassword = HashPassword(salt, newPassword);

            user.Salt = salt;
            user.HashedPassword = hashedPassword;
            user.UpdatedAt = DateTime.Now;
            _context.SaveChanges();

            var message = new MimeMessage();
            message.From.Add(new MailboxAddress("아바라", "contact@hilabs.co.kr"));
            message.To.Add(new MailboxAddress(user.UserName, user.Email));
            message.Subject = "아바라 계정 - 새로운 암호가 설정되었습니다";

            var bb = new BodyBuilder();
            bb.TextBody = $"새로운 암호는 {newPassword} 입니다";
            message.Body = bb.ToMessageBody();

            if (IsRelease)
            {
                using var client = new SmtpClient();
                client.Connect("127.0.0.1", 25, false);
                client.Send(message);
                client.Disconnect(true);
            }

            return Ok(new { isSuccess = true, responseMessage = "새로운 암호가 설정되어 메일로 전송되었습니다" });
        }

        [AllowAnonymous]
        [HttpPost("login")]
        public async Task<IActionResult> LogIn([FromForm] string email, [FromForm] string password)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 입력해주세요" });
            }
            if (IsValidEmail(email) == false)
            {
                return Ok(new { isSuccess = false, responseMessage = "이메일을 형식을 확인해주세요" });
            }

            if (string.IsNullOrWhiteSpace(password))
            {
                return Ok(new { isSuccess = false, responseMessage = "암호를 입력해주세요" });
            }

            await Task.Delay(500);

            var user = _context.User.SingleOrDefault(m => m.Email == email);
            if (user == null)
            {
                return Ok(new { isSuccess = false, responseMessage = "등록된 이메일이 아닙니다" });
            }

            var hashedPassword = HashPassword(user.Salt, password);
            if (user.HashedPassword != hashedPassword)
            {
                return Ok(new { isSuccess = false, responseMessage = "암호가 일치하지 않습니다" });
            }

            var newSession = new Session { User = user, CreatedAt = DateTime.Now, UpdatedAt = DateTime.Now, IsExpired = false };
            _context.Add(newSession);
            _context.SaveChanges();

            var claims = new List<Claim>
            {
                new Claim(ClaimTypes.Role, "User"),
                new Claim("myUserId", user.UserId),
                new Claim("myEmail", user.Email),
                new Claim("mySessionId", newSession.SessionId.ToString()),
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var key = Encoding.ASCII.GetBytes(SecurityKeyString);
            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = (IsDebug) ? DateTime.Now.AddDays(3) : DateTime.Now.AddYears(3),
                SigningCredentials = new SigningCredentials(new SymmetricSecurityKey(key), SecurityAlgorithms.HmacSha256Signature),
            };

            var securityToken = tokenHandler.CreateToken(tokenDescriptor);
            var accessToken = tokenHandler.WriteToken(securityToken);

            user.LastLoginAt = DateTime.Now;
            _context.SaveChanges();

            return Ok(new
            {
                isSuccess = true,
                accessToken,
                user = new
                {
                    user.UserId,
                    user.UserName,
                    user.Email,
                    user.SchoolName,
                    user.Comment,
                    user.ProfileImage,
                    user.AllowOthersToFindMe,
                },
            });
        }

        [HttpPost("edit/me/allow-others-to-find-me")]
        public IActionResult EditMeAllowOthersToFindMe([FromForm] string allowOthersToFindMe)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var userMe = _context.User.SingleOrDefault(m => m.UserId == myUserId);
            if (userMe == null) return NotFound();

            var responseMessage = "";

            if (allowOthersToFindMe == "on")
            {
                userMe.AllowOthersToFindMe = true;
                userMe.UpdatedAt = DateTime.Now;
                _context.SaveChanges();

                responseMessage = "친구찾기가 활성화되었습니다";
            }
            else if (allowOthersToFindMe == "off")
            {
                userMe.AllowOthersToFindMe = false;
                userMe.UpdatedAt = DateTime.Now;
                _context.SaveChanges();

                responseMessage = "친구찾기가 비활성화되었습니다";
            }
            else { return NotFound(); }

            return Ok(new
            {
                isSuccess = true,
                responseMessage,
                user = new
                {
                    userMe.UserId,
                    userMe.UserName,
                    userMe.Email,
                    userMe.SchoolName,
                    userMe.Comment,
                    userMe.ProfileImage,
                    userMe.AllowOthersToFindMe,
                },
            });
        }

        [HttpGet("edit/me")]
        public IActionResult EditMe()
        {
            var myUserId = User.FindFirstValue("myUserId");

            var user = _context.User.AsNoTracking().SingleOrDefault(m => m.UserId == myUserId);
            if (user == null) return NotFound();

            return Ok(new
            {
                user = new
                {
                    user.UserId,
                    user.UserName,
                    user.Email,
                    user.SchoolName,
                    user.Comment,
                    user.ProfileImage,
                    user.AllowOthersToFindMe,
                },
            });
        }

        [HttpPost("edit/me")]
        public async Task<IActionResult> EditMe([FromForm] string userName, [FromForm] string comment, IFormFile fileProfileImage)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var userMe = _context.User.SingleOrDefault(m => m.UserId == myUserId);
            if (userMe == null) return NotFound();

            userName = (userName ?? "").Trim();
            comment = (comment ?? "").Trim();

            if (userName.Length < 2) return Ok(new { isSuccess = false, responseMessage = "이름을 2자 이상 입력해주세요" });
            if (userName.Length > 20) return Ok(new { isSuccess = false, responseMessage = "이름을 20자 이하로 입력해주세요" });
            if (comment.Length > 20) return Ok(new { isSuccess = false, responseMessage = "Comment 를 20자 이하로 입력해주세요" });

            var listFile = new List<IFormFile>
            {
                fileProfileImage
            };

            var listFileName = new List<string>();
            string profileImage = null;

            var listToDeleteOnException = new List<string>();

            try
            {
                for (int i = 0; i < 1; i++)
                {
                    listFileName.Add("_");

                    Print("listFile[" + i + "] == null " + (listFile[i] == null));

                    if (listFile[i]?.Length > 0)
                    {
                        PrintIFormFile(listFile[i]);

                        EnsurePngOrJpeg(listFile[i].FileName);

                        var newPath1 = "";
                        do
                        {
                            newPath1 = GetImagePath("user", GenerateNewFileName(listFile[i].FileName));

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

                        profileImage = Path.GetFileName(newPath1);

                        var newPath2 = GetImagePath("user-resized-1020", profileImage);

                        using (var image = Image.Load(newPath1))
                        {
                            listFileName[i] = Path.GetFileName(newPath1);

                            var w = 340 * 3;
                            image.Mutate(x => x.Resize(w, image.Height * w / image.Width));
                            image.Save(newPath2);
                        }
                        listToDeleteOnException.Add(newPath2);

                        var newPath3 = GetImagePath("user-resized-0184", profileImage);

                        using (var image = Image.Load(newPath1))
                        {
                            listFileName[i] = Path.GetFileName(newPath1);

                            var w = 46 * 4;
                            image.Mutate(x => x.Resize(w, image.Height * w / image.Width));
                            image.Save(newPath3);
                        }
                        listToDeleteOnException.Add(newPath3);
                    }
                }
            }
            catch (Exception)
            {
                await DeleteFiles(listToDeleteOnException);

                return Ok(new { isSuccess = false, responseMessage = "파일 처리 중 에러가 발생하였습니다" });
            }

            userMe.UserName = userName;
            userMe.Comment = comment;
            if (profileImage != null) userMe.ProfileImage = profileImage;
            userMe.UpdatedAt = DateTime.Now;
            _context.SaveChanges();

            return Ok(new
            {
                isSuccess = true,
                responseMessage = "수정되었습니다",
                user = new
                {
                    userMe.UserId,
                    userMe.UserName,
                    userMe.Email,
                    userMe.SchoolName,
                    userMe.Comment,
                    userMe.ProfileImage,
                    userMe.AllowOthersToFindMe,
                },
            });
        }

        [HttpGet("list")]
        public IActionResult List(int page = 1)
        {
            var myUserId = User.FindFirstValue("myUserId");

            var source = _context.User.AsNoTracking().Where(m => m.AllowOthersToFindMe == true);

            var pageSize = 10;
            var listUser = source.OrderByDescending(m => m.LastLoginAt).Skip((page - 1) * pageSize).Take(pageSize).Select(m => new
            {
                m.UserId,
                m.UserName,
                m.SchoolName,
                m.ProfileImage,
                relationshipScore = _context.RelationshipScoreFriend.Single(mm => mm.UserId1 == myUserId && mm.UserId2 == m.UserId).ReferenceScore ?? -1,
            }).ToList();

            return Ok(new
            {
                listUser
            });
        }

    }
}
