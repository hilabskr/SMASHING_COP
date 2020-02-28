using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using AbaraWebApplication.Models;

namespace AbaraWebApplication.Data
{
    public class WebApplicationContext : DbContext
    {
        public WebApplicationContext(DbContextOptions<WebApplicationContext> options) : base(options)
        {
        }

        public DbSet<School> School { get; set; }
        public DbSet<UserVerification> UserVerification { get; set; }
        public DbSet<User> User { get; set; }
        public DbSet<Session> Session { get; set; }
        public DbSet<Article> Article { get; set; }
        public DbSet<ArticleComment> ArticleComment { get; set; }
        public DbSet<Bookmark> Bookmark { get; set; }
        public DbSet<PersonalNotification> PersonalNotification { get; set; }
        public DbSet<ChatRoom> ChatRoom { get; set; }
        public DbSet<ChatMessage> ChatMessage { get; set; }
        public DbSet<CurrentActiveUser> CurrentActiveUser { get; set; }
        public DbSet<WeatherInfo> WeatherInfo { get; set; }
        public DbSet<RelationshipScoreArticleFree> RelationshipScoreArticleFree { get; set; }
        public DbSet<RelationshipScoreArticleMarket> RelationshipScoreArticleMarket { get; set; }
        public DbSet<RelationshipScoreFriend> RelationshipScoreFriend { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {

            modelBuilder.Entity("AbaraWebApplication.Models.Session", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User")
                    .WithMany()
                    .HasForeignKey("UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.Article", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User")
                    .WithMany()
                    .HasForeignKey("UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ArticleComment", b =>
            {
                b.HasOne("AbaraWebApplication.Models.Article", "Article")
                    .WithMany()
                    .HasForeignKey("ArticleId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ArticleComment", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User")
                    .WithMany()
                    .HasForeignKey("UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.Bookmark", b =>
            {
                b.HasOne("AbaraWebApplication.Models.Article", "Article")
                    .WithMany()
                    .HasForeignKey("ArticleId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.Bookmark", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User")
                    .WithMany()
                    .HasForeignKey("UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.PersonalNotification", b =>
            {
                b.HasOne("AbaraWebApplication.Models.Article", "Article")
                    .WithMany()
                    .HasForeignKey("ArticleId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.PersonalNotification", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "FromUser")
                    .WithMany()
                    .HasForeignKey("FromUserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.PersonalNotification", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "ToUser")
                    .WithMany()
                    .HasForeignKey("ToUserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ChatRoom", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User1")
                    .WithMany()
                    .HasForeignKey("User1UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ChatRoom", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User2")
                    .WithMany()
                    .HasForeignKey("User2UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ChatMessage", b =>
            {
                b.HasOne("AbaraWebApplication.Models.ChatRoom", "ChatRoom")
                    .WithMany()
                    .HasForeignKey("ChatRoomId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity("AbaraWebApplication.Models.ChatMessage", b =>
            {
                b.HasOne("AbaraWebApplication.Models.User", "User")
                    .WithMany()
                    .HasForeignKey("UserId")
                    .OnDelete(DeleteBehavior.Restrict);
            });

            modelBuilder.Entity<User>().HasIndex(b => b.Email).IsUnique();
            modelBuilder.Entity<User>().HasIndex(b => b.LastLoginAt);

            modelBuilder.Entity<Session>().HasIndex(b => b.FirebaseToken);

        }
    }
}

