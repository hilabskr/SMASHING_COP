using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class CurrentActiveUser
    {
        [Column(TypeName = "char(6)"), Key]
        public string UserId { get; set; }

        public bool? IsActive { get; set; }

        public DateTime? UpdatedAt { get; set; }
    }
}
