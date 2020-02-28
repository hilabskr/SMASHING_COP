using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class WeatherInfo
    {
        [Column(TypeName = "char(6)"), Key]
        public string UserId { get; set; }

        public int WeatherCode { get; set; }
    }
}
