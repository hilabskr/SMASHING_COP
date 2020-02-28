using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class ArticleComment
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public int ArticleCommentId { get; set; }

        [Required]
        public Article Article { get; set; }

        [Required]
        public User User { get; set; }

        [Column(TypeName = "nvarchar(max)")]
        [Required]
        public string Comment { get; set; }

        [Column(TypeName = "varchar(45)")]
        [Required]
        public string RemoteIpAddress { get; set; }

        [Required]
        public DateTime InsertedAt { get; set; }

        [Required]
        public DateTime UpdatedAt { get; set; }

        [Required]
        public bool IsDeleted { get; set; }

        [Required]
        public bool IsBlinded { get; set; }
    }
}
