using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class ChatRoom
    {
        [DatabaseGenerated(DatabaseGeneratedOption.Identity), Key]
        public long ChatRoomId { get; set; }

        [ForeignKey("User1UserId")]
        [Required]
        public User User1 { get; set; }

        [ForeignKey("User2UserId")]
        [Required]
        public User User2 { get; set; }

        [Required]
        public int User1NewCount { get; set; }

        [Required]
        public int User2NewCount { get; set; }

        [Required]
        public DateTime CreatedAt { get; set; }

        [Required]
        public DateTime UpdatedAt { get; set; }

        [ForeignKey("LastChatMessageId")]
        public ChatMessage LastChatMessage { get; set; }

    }
}
