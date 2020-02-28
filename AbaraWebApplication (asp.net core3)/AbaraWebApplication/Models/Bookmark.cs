using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class Bookmark
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public int BookmarkId { get; set; }

        [Required]
        public Article Article { get; set; }

        [Required]
        public User User { get; set; }

        [Required]
        public DateTime InsertedAt { get; set; }
    }
}
