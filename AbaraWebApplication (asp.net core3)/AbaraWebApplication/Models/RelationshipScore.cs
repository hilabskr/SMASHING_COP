using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace AbaraWebApplication.Models
{
    public class RelationshipScoreArticleFree
    {
        [Key]
        public string RelationshipId { get; set; }

        public string UserId { get; set; }

        public int ArticleId { get; set; }

        public int? RelationshipScore { get; set; }

        public int? RelationshipScoreOld { get; set; }

        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime? UpdatedAt { get; set; }
    }

    public class RelationshipScoreArticleMarket
    {
        [Key]
        public string RelationshipId { get; set; }

        public string UserId { get; set; }

        public int ArticleId { get; set; }

        public int? RelationshipScore { get; set; }

        public int? RelationshipScoreOld { get; set; }

        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime? UpdatedAt { get; set; }
    }

    public class RelationshipScoreFriend
    {
        [Key]
        public string RelationshipId { get; set; }

        public string UserId1 { get; set; }

        public string UserId2 { get; set; }

        public int? ReferenceScore { get; set; }

        public int? ReferenceScoreOld { get; set; }

        [DisplayFormat(DataFormatString = "{0:yyyy-MM-dd HH:mm}")]
        public DateTime? UpdatedAt { get; set; }
    }
}
