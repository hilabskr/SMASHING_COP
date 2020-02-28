using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class UserVerification
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public long UserVerificationId { get; set; }

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

        [Column(TypeName = "char(4)")]
        [Display(Name = "인증번호")]
        [Required]
        public string VerificationCode { get; set; }

        [Display(Name = "생성시간")]
        public DateTime CreatedAt { get; set; }

        [Display(Name = "실패횟수")]
        public int FailCount { get; set; }

        [Display(Name = "성공여부")]
        public bool HasSuccess { get; set; }
    }
}
