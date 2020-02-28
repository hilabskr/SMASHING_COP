using AbaraWebApplication.Data;
using AbaraWebApplication.Extras;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Authentication.Cookies;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.HttpOverrides;
using Microsoft.AspNetCore.Localization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using System;
using System.Globalization;
using System.Text;
using System.Threading.Tasks;
using static AbaraWebApplication.Extras.ProjectHelpers;

namespace AbaraWebApplication
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        public void ConfigureServices(IServiceCollection services)
        {
            if (IsDebug)
            {
                services.AddControllersWithViews().AddRazorRuntimeCompilation();
            }
            else
            {
                services.AddControllersWithViews();
            }

            services.AddMvc(options =>
            {
                options.CacheProfiles.Add("Default",
                    new CacheProfile()
                    {
                        Duration = 60,
                    });
                options.CacheProfiles.Add("Cache",
                    new CacheProfile()
                    {
                        Duration = 86400 * 365,
                    });
                options.CacheProfiles.Add("NoStore",
                    new CacheProfile()
                    {
                        Location = ResponseCacheLocation.None,
                        NoStore = true,
                    });
            }).SetCompatibilityVersion(CompatibilityVersion.Version_3_0);

            services.AddDbContext<WebApplicationContext>(options => options.UseSqlServer(DefaultConnection));

            services.AddApiVersioning(options =>
                {
                    options.ReportApiVersions = true;
                }
            );

            var key = Encoding.ASCII.GetBytes(ProjectHelpers.SecurityKeyString);

            services.AddAuthentication()
            .AddCookie(options =>
            {
                options.Events.OnRedirectToLogin = RedirectTo;
                options.Events.OnRedirectToAccessDenied = RedirectTo;
            })
            .AddJwtBearer(options =>
            {
                options.RequireHttpsMetadata = false;
                options.SaveToken = true;
                options.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.Zero,

                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = new SymmetricSecurityKey(key),
                    ValidateIssuer = false,
                    ValidateAudience = false,
                };
            });

            if (ShowSwagger)
            {
                services.AddSwaggerGen(c =>
                {
                    c.SwaggerDoc("v1", new OpenApiInfo
                    {
                        Version = "v1",
                        Title = "API",
                        Description = "Description",
                    });
                });
            }
        }

        private Task RedirectTo(RedirectContext<CookieAuthenticationOptions> redirectContext)
        {

            if (redirectContext.Request.Path.Value.StartsWith("/admin"))
            {
                redirectContext.Response.Redirect("/admin/login");
            }

            return Task.CompletedTask;
        }

        public void Configure(IApplicationBuilder app, IWebHostEnvironment env)
        {
            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }
            else
            {
                app.UseExceptionHandler("/error");

            }

            app.UseForwardedHeaders(new ForwardedHeadersOptions
            {
                ForwardedHeaders = ForwardedHeaders.All
            });

            var supportedCultures = new[]
            {
                new CultureInfo("ko-KR"),
            };

            app.UseRequestLocalization(new RequestLocalizationOptions
            {
                DefaultRequestCulture = new RequestCulture("ko-KR"),
                SupportedCultures = supportedCultures,
                SupportedUICultures = supportedCultures
            });

            app.UseStaticFiles();

            app.UseCookiePolicy();

            app.UseRouting();
            app.UseAuthentication();
            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });

            if (ShowSwagger)
            {
                app.UseSwagger();

                app.UseSwaggerUI(c =>
                {
                    c.SwaggerEndpoint("/swagger/v1/swagger.json", "My API V1");
                });
            }
        }
    }
}
