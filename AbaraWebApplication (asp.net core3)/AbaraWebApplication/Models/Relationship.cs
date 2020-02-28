using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class Relationship
    {
        [Column(TypeName = "char(12)"), Key]
        public string RelationshipId { get; set; }

        [ForeignKey("User1UserId")]
        [Required]
        public User User1 { get; set; }

        [ForeignKey("User2UserId")]
        [Required]
        public User User2 { get; set; }

        public int MatchingScore { get; set; }
    }
}
