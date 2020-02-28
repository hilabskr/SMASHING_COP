using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class School
    {
        [Column(TypeName = "nvarchar(50)"), Key]
        [Display(Name = "학교")]
        [Required]
        public string SchoolId { get; set; }

        [Column(TypeName = "nvarchar(30)")]
        [Display(Name = "학교")]
        [Required]
        public string SchoolName { get; set; }

        [Column(TypeName = "varchar(100)")]
        [Display(Name = "도메인")]
        [Required]
        public string Domain { get; set; }

        [Display(Name = "입력시간")]
        [DisplayFormat(DataFormatString = "{0:yyyy.MM.dd}")]
        public DateTime InsertedAt { get; set; }
    }
}
