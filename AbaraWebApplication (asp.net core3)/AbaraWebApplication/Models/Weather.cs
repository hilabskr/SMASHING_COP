using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class Weather
    {
        public string Icon { get; set; }

        public string Temperature { get; set; }

        public DateTime CreatedAt { get; set; }
    }
}
