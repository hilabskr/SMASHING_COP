using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class Session
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public long SessionId { get; set; }

        [Required]
        public User User { get; set; }

        [Column(TypeName = "varchar(200)")]
        public string FirebaseToken { get; set; }

        [Display(Name = "앱버전")]
        [Column(TypeName = "varchar(20)")]
        public string AppVersion { get; set; }

        [Display(Name = "OS")]
        [Column(TypeName = "char(1)")]
        public string PlatformType { get; set; }

        [Display(Name = "OS버전")]
        [Column(TypeName = "varchar(30)")]
        public string PlatformVersion { get; set; }

        [Column(TypeName = "varchar(45)")]
        public string RemoteIpAddress { get; set; }

        [Display(Name = "생성일")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime CreatedAt { get; set; }

        [Display(Name = "갱신일")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime UpdatedAt { get; set; }

        [Display(Name = "로그아웃")]
        [Required]
        public bool IsExpired { get; set; }
    }
}
