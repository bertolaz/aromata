using Aromata.Application.Common.Interfaces;
using Aromata.Domain.Constants;
using Aromata.Infrastructure.Data;
using Aromata.Infrastructure.Identity;
using Aromata.Web.Infrastructure;
using Aromata.Web.Services;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace Aromata.Web;

public static class DependencyInjection
{
    public static void AddWebServices(this IHostApplicationBuilder builder)
    {
        builder.Services.AddScoped<IUser, CurrentUser>();
        builder.Services.AddHttpContextAccessor();
        builder.Services.AddExceptionHandler<CustomExceptionHandler>();
        builder.Services.AddDatabaseDeveloperPageExceptionFilter();

        builder.Services.AddAuthentication(options =>
            {
                options.DefaultScheme = IdentityConstants.ApplicationScheme;
                options.DefaultSignInScheme = IdentityConstants.ExternalScheme;
            })
            .AddIdentityCookies();
        builder.Services.AddAuthorization();
    }
    
    public static async Task ApplyMigrations(this WebApplication app)
    {
        await using var scope = app.Services.CreateAsyncScope();
        var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
        var pendingMigrations = await dbContext.Database.GetPendingMigrationsAsync();
        if(!pendingMigrations.Any())return;
        await dbContext.Database.MigrateAsync();
    }
    public static async Task SeedAdminUser(this WebApplication app, string email, string password)
    {
        await using var scope = app.Services.CreateAsyncScope();
        var userManager = scope.ServiceProvider.GetRequiredService<UserManager<ApplicationUser>>();
        var roleManager = scope.ServiceProvider.GetRequiredService<RoleManager<IdentityRole>>();
        var adminUsers = await userManager.GetUsersInRoleAsync(Roles.Administrator);
        if (adminUsers.Any()) return;

        var user = await userManager.FindByEmailAsync(email);
        if (user is null)
        {
            user = new ApplicationUser()
            {
                UserName = email,
                Email = email,
                EmailConfirmed = true
            };
            var result = await userManager.CreateAsync(user, password);
            if (!result.Succeeded) throw new Exception("Could not create admin user");
        }

        await AddUserToRole(userManager, roleManager, user, Roles.Administrator);
    }

    private static async Task AddUserToRole(UserManager<ApplicationUser> userManager,
        RoleManager<IdentityRole> roleManager, ApplicationUser user, string roleName)
    {
        var role = await roleManager.FindByNameAsync(roleName);
        if (role is null)
        {
            role = new IdentityRole()
            {
                Name = roleName
            };
            await roleManager.CreateAsync(role);
        }

        var r = await userManager.IsInRoleAsync(user, role.Name!);
        if (r) return;

        var res = await userManager.AddToRoleAsync(user, role.Name!);
        if (!res.Succeeded) throw new Exception($"Could not add user {user.UserName} to role {roleName}");
    }
}