using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class Article
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        [Display(Name = "글번호")]
        public int ArticleId { get; set; }

        [Display(Name = "작성자")]
        [Required]
        public User User { get; set; }

        [Column(TypeName = "char(2)")]
        [Display(Name = "분류1")]
        [Required]
        public string Category1 { get; set; }

        [Column(TypeName = "nvarchar(20)")]
        [Display(Name = "분류2")]
        public string Category2 { get; set; }

        [Column(TypeName = "nvarchar(50)")]
        [Display(Name = "제목")]
        [Required]
        public string Subject { get; set; }

        [Column(TypeName = "varchar(200)")]
        [Required]
        public string FileNames { get; set; }

        [Column(TypeName = "varchar(200)")]
        [Required]
        public string FileProperties { get; set; }

        [Column(TypeName = "char(20)")]
        [Display(Name = "커버사진")]
        public string CoverImage { get; set; }

        [Column(TypeName = "nvarchar(max)")]
        [Display(Name = "내용")]
        [Required]
        public string Content { get; set; }

        [Column(TypeName = "varchar(max)")]
        [Display(Name = "조회한 회원")]
        [Required]
        public string ViewUserIds { get; set; }

        [Display(Name = "조회수")]
        [Required]
        public int ViewCount { get; set; }

        [Column(TypeName = "varchar(max)")]
        [Display(Name = "좋아요한 회원")]
        [Required]
        public string UpvoteUserIds { get; set; }

        [Column(TypeName = "varchar(70)")]
        [Required]
        public string UpvoteProfileImages { get; set; }

        [Display(Name = "좋아요수")]
        [Required]
        public int UpvoteCount { get; set; }

        [Display(Name = "댓글수")]
        [Required]
        public int CommentCount { get; set; }

        [Column(TypeName = "varchar(45)")]
        [Display(Name = "입력IP")]
        [Required]
        public string RemoteIpAddress { get; set; }

        [Display(Name = "입력시간")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        [Required]
        public DateTime InsertedAt { get; set; }

        [Display(Name = "수정시간")]
        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        [Required]
        public DateTime UpdatedAt { get; set; }

        [Display(Name = "진행중")]
        [Required]
        public bool IsOngoing { get; set; }

        [Display(Name = "삭제여부")]
        [Required]
        public bool IsDeleted { get; set; }

        [Display(Name = "Blind여부")]
        [Required]
        public bool IsBlinded { get; set; }
    }
}
