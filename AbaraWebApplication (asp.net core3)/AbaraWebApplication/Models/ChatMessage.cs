using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class ChatMessage
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public long ChatMessageId { get; set; }

        [Required]
        public ChatRoom ChatRoom { get; set; }

        [Required]
        public User User { get; set; }

        [Column(TypeName = "nvarchar(4000)")]
        [Required]
        public string Message { get; set; }

        [Required]
        public bool IsNewDay { get; set; }

        [Required]
        public bool IsBlinded { get; set; }

        [Required]
        public DateTime InsertedAt { get; set; }
    }
}
