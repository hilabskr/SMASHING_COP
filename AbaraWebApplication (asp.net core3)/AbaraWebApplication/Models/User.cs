using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class User
    {
        [Column(TypeName = "char(6)"), Key]
        [Display(Name = "회원ID")]
        public string UserId { get; set; }

        [Column(TypeName = "nvarchar(20)")]
        [Display(Name = "회원이름")]
        [Required]
        public string UserName { get; set; }

        [Column(TypeName = "varchar(100)")]
        [Display(Name = "이메일")]
        [Required]
        public string Email { get; set; }

        [Column(TypeName = "nvarchar(30)")]
        [Display(Name = "학교")]
        [Required]
        public string SchoolName { get; set; }

        [Column(TypeName = "char(24)")]
        [Display(Name = "솔트")]
        [Required]
        public string Salt { get; set; }

        [Column(TypeName = "char(44)")]
        [Display(Name = "해시된 암호")]
        [Required]
        public string HashedPassword { get; set; }

        [Column(TypeName = "char(1)")]
        [Display(Name = "성별")]
        [Required]
        public string Gender { get; set; }

        [Display(Name = "생년")]
        [Required]
        public int BirthYear { get; set; }

        [Column(TypeName = "nvarchar(20)")]
        [Display(Name = "소개글")]
        public string Comment { get; set; }

        [Column(TypeName = "char(20)")]
        [Display(Name = "회원사진")]
        public string ProfileImage { get; set; }

        [Display(Name = "가입일")]
        [DisplayFormat(DataFormatString = "{0:yyyy.MM.dd}")]
        public DateTime SignUpAt { get; set; }

        [Display(Name = "수정일")]
        [DisplayFormat(DataFormatString = "{0:yyyy.MM.dd}")]
        public DateTime UpdatedAt { get; set; }

        [Display(Name = "최근 로그인")]
        [DisplayFormat(DataFormatString = "{0:yyyy.MM.dd}")]
        public DateTime LastLoginAt { get; set; }

        [Display(Name = "친구찾기 공개")]
        [Required]
        public bool AllowOthersToFindMe { get; set; }
    }
}
