using AbaraWebApplication.Data;
using Microsoft.AspNetCore.Cryptography.KeyDerivation;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;
using System.Text.RegularExpressions;
using System.Threading.Tasks;

namespace AbaraWebApplication.Extras
{
    public static class ProjectHelpers
    {
#if DEBUG
        public static bool IsDebug { get => true; }
#else
        public static bool IsDebug { get => false; }
#endif
#if RELEASE
        public static bool IsRelease { get => true; }
#else
        public static bool IsRelease { get => false; }
#endif
        public static bool ShowSwagger { get => true; }
        public static int MaxNotificationCount { get => 2; }
        public static string ProjectName { get => "ABARA"; }
        public static string DefaultConnection { get => "Server=59.9.20.27,10433\\SQLEXPRESS;Database=Abara;User Id=abara;Password=TD6JhnZ9DbnHPA;Encrypt=True;TrustServerCertificate=True;"; }

        public static string SecurityKeyString { get => "EAAoIBAgkqhkiG9QC30BvjXdxYQ3bEB5KcwgvQIBADAdNBw80BAQEFAdASCgSjAg"; }
        public static string FirebaseServerKey { get => "AAAA3tXQmOs:APA91bHxDCOGu8qo5A3txEFPr-304lyO1cgWgYJJh-K4GjkTTXWKjwznKJQaiqrFEWjM9NwWvEogt7AL1UUjFi4KxRQ-PFTmLZ8pgCS5fSMfHi72PqaC8p_wu7S_O7D1cSiDGIrXSu16"; }
        public static string OpenWeatherMapAppId { get => "7438b8e2327e966ea3a44e0b780a2132"; } // https://home.openweathermap.org/api_keys contact@hilabs.co.kr 4ZFTn...
        public static string AdminPassword { get => "333"; }
        public static int VerificationCodeExpireHour { get => 3; }
        public static int VerificationCodeMaxFailCount { get => 3; }
        public static string BlindedChatMessage { get => "매쉬업 알고리즘으로 인해 본 게시물/메세지는 선제적 차단되었습니다"; }
        public static Dictionary<string, string> DicUrlCategory1
        {
            get => new Dictionary<string, string> {
                { "free", "FR" },
                { "market", "MK" },
                { "job", "JB" },
                { "contest", "CT" },
                { "scholarship", "SS" },
            };
        }
        public static Dictionary<string, string> DicCategory1Url
        {
            get => new Dictionary<string, string> {
                { "FR", "free" },
                { "MK", "market" },
                { "JB", "job" },
                { "CT", "contest" },
                { "SS", "scholarship" },
            };
        }
        public static Dictionary<string, string> DicCategory1Name
        {
            get => new Dictionary<string, string> {
                { "FR", "자유게시판" },
                { "MK", "중고마켓" },
                { "JB", "구직구인" },
                { "CT", "공모전" },
                { "SS", "장학금" },
            };
        }

        public static string Cut(this string value, int limit, string appendix)
        {
            if (value == null) return "";
            return (value.Length > limit) ? value.Substring(0, limit - appendix.Length) + appendix : value;
        }

        public static void EnsurePngOrJpeg(string fileName)
        {
            var extension = Path.GetExtension(fileName).ToLower();
            if (extension != ".jpg" && extension != ".jpeg" && extension != ".png") throw new Exception("첨부파일을 jpg jpeg png 로 올려주세요");
        }

        public static string GenerateNewFileName(string fileName)
        {
            EnsurePngOrJpeg(fileName);

            var extension = Path.GetExtension(fileName).ToLower();
            if (extension == ".jpeg") extension = ".jpg";

            var chars = "bcdfghjklmnpqrstvwxz0123456789";

            var random = new Random();
            var sb = new StringBuilder();
            for (int i = 0; i < 16; i++)
            {
                sb.Append(chars[random.Next(chars.Length)]);
            }

            return sb.ToString() + extension;
        }

        public static string GetImagePath(string category, string fileName)
        {
            var basePath = (Environment.OSVersion.Platform == PlatformID.Win32NT) ? @"C:\Users\w10\Desktop\TempImage\" : "/usr/hilabs/image/";

            return Path.Combine(basePath, category, fileName);
        }

        public static void DeleteFile(string path)
        {
            if (File.Exists(path)) File.Delete(path);
        }

        public static async Task DeleteFiles(List<string> listPath)
        {
#if DEBUG
            await Task.Delay(1000);
#endif
            await Task.Delay(10);
            listPath.ForEach(f => DeleteFile(f));
        }

        public static void Print(object o)
        {
#if DEBUG
            Console.WriteLine("~~~~~~~~~~~ " + DateTime.Now.ToString("HH:mm:ss.fff ") + o);
#endif
        }

        public static void PrintIFormFile(IFormFile file)
        {
#if DEBUG
            Print(file.Length + "___" + file.Name + "___" + file.FileName + "___" + file.ContentType + "___" + file.ContentDisposition);
#endif
        }

        public static bool IsValidEmail(string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return false;

            try
            {
                return Regex.IsMatch(email,
                    @"^(?("")("".+?(?<!\\)""@)|(([0-9a-z]((\.(?!\.))|[-!#\$%&'\*\+/=\?\^`\{\}\|~\w])*)(?<=[0-9a-z])@))" +
                    @"(?(\[)(\[(\d{1,3}\.){3}\d{1,3}\])|(([0-9a-z][-0-9a-z]*[0-9a-z]*\.)+[a-z0-9][\-a-z0-9]{0,22}[a-z0-9]))$",
                    RegexOptions.IgnoreCase, TimeSpan.FromMilliseconds(250));
            }
            catch (RegexMatchTimeoutException)
            {
                return false;
            }
        }

        public static string GenerateSalt()
        {
            byte[] salt = new byte[128 / 8];
            using (var rng = RandomNumberGenerator.Create())
            {
                rng.GetBytes(salt);
            }
            return Convert.ToBase64String(salt);
        }

        public static string HashPassword(string salt, string password)
        {
            return Convert.ToBase64String(KeyDerivation.Pbkdf2(
                password: password,
                salt: Convert.FromBase64String(salt),
                prf: KeyDerivationPrf.HMACSHA1,
                iterationCount: 10000,
                numBytesRequested: 256 / 8));
        }

        public static string GenerateRandom20(int length)
        {
            var chars = "bcdfghjklmnpqrstvwxz";

            var random = new Random();
            var sb = new StringBuilder();
            for (int i = 0; i < length; i++)
            {
                sb.Append(chars[random.Next(chars.Length)]);
            }

            return sb.ToString();
        }

        public static string GetDiff(DateTime dt)
        {
            var diff = DateTime.Now - dt;
            if (diff.Days > 30) return dt.ToString("dd MMMM yyyy", CultureInfo.CreateSpecificCulture("en-US"));
            else if (diff.Days > 1) return diff.Days + "d";
            else if (diff.Days == 1) return diff.Days + "d";
            else if (diff.Hours > 1) return diff.Hours + "h";
            else if (diff.Hours == 1) return diff.Hours + "h";
            else if (diff.Minutes > 1) return diff.Minutes + "min";
            else if (diff.Minutes == 1) return diff.Minutes + "min";
            else return "just now";

        }

        public static void SendPushNotification(WebApplicationContext context, string userId, string command, string title = null, string body = null)
        {

            var listToken = context.Session.AsNoTracking().Where(m => m.User.UserId == userId && m.IsExpired == false && m.FirebaseToken != null).OrderByDescending(m => m.UpdatedAt).Select(m => m.FirebaseToken).ToList();

            Print("listToken.Count " + listToken.Count);

            var listTokenDone = new List<string>();
            for (int i = 0; i < listToken.Count; i++)
            {
                if (listTokenDone.Contains(listToken[i]) == false)
                {
                    SendPushNotification(listToken[i], command, title, body);

                    listTokenDone.Add(listToken[i]);
                    if (listTokenDone.Count >= MaxNotificationCount) break;
                }
                else
                {
                    Print("listTokenDone.Contains~~~~ " + listToken[i]);
                }
            }
        }

        public static bool SendPushNotification(string fbToken, string command, string title = null, string body = null)
        {
            string url = "https://fcm.googleapis.com/fcm/send";

            string result = null;

            try
            {
                var payload1 = new
                {
                    to = fbToken,
                    priority = "high",
                    notification = new
                    {
                        title,
                        body,
                        sound = "default",
                    },
                    data = new
                    {
                        command,
                        click_action = "FLUTTER_NOTIFICATION_CLICK",
                    },
                };

                var payload2 = new
                {
                    to = fbToken,
                    priority = "high",
                    data = new
                    {
                        command,
                        click_action = "FLUTTER_NOTIFICATION_CLICK",
                    },
                };

                var options = new JsonSerializerOptions
                {
                    PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
                    WriteIndented = true,
                };

                var jsonPayload = (title != null && body != null) ?
                    JsonSerializer.Serialize(payload1, options) :
                    JsonSerializer.Serialize(payload2, options);
                Print(jsonPayload);

                WebRequest wrq = WebRequest.Create(url);
                wrq.Method = "POST";
                wrq.ContentType = "application/json";
                wrq.Headers.Add("Authorization: key=" + FirebaseServerKey);

                byte[] bytePayload = Encoding.UTF8.GetBytes(jsonPayload);
                wrq.ContentLength = bytePayload.Length;

                Stream streamSend = wrq.GetRequestStream();
                streamSend.Write(bytePayload, 0, bytePayload.Length);
                streamSend.Close();

                using (StreamReader sr = new StreamReader(wrq.GetResponse().GetResponseStream()))
                {
                    result = sr.ReadToEnd();
                }
            }
            catch (Exception ex)
            {
                Print(ex);
            }

            Print(fbToken);
            Print(result);

            return (result != null && result.IndexOf("\"success\":1,") != -1);
        }
    }
}
