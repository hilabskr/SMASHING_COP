using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class PersonalNotification
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public long PersonalNotificationId { get; set; }

        [Required]
        public Article Article { get; set; }

        [ForeignKey("FromUserId")]
        [Required]
        public User FromUser { get; set; }

        [ForeignKey("ToUserId")]
        [Required]
        public User ToUser { get; set; }

        [Column(TypeName = "char(2)")]
        [Required]
        public string NotificationType { get; set; }

        [Column(TypeName = "nvarchar(200)")]
        [Required]
        public string Content { get; set; }

        [Required]
        public DateTime InsertedAt { get; set; }

        [Required]
        public bool HasChecked { get; set; }

        [Required]
        public DateTime CheckedAt { get; set; }
    }
}
