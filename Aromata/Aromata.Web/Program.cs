using Ardalis.GuardClauses;
using Aromata.Application;
using Aromata.Infrastructure;
using Aromata.Infrastructure.Data;
using Aromata.Web;
using Aromata.Web.Components;
using Aromata.Web.Infrastructure;
using MudBlazor.Services;
using ServiceDefaults;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddRazorComponents()
    .AddInteractiveWebAssemblyComponents()
    .AddAuthenticationStateSerialization();

builder.Services.AddMudServices();
builder.Services.AddCascadingAuthenticationState();
builder.AddApplicationServices();
builder.AddInfrastructureServices();
builder.AddWebServices();
builder.AddServiceDefaults();

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseWebAssemblyDebugging();
    app.UseMigrationsEndPoint();
    var adminEmail = app.Configuration["AdminEmail"];
    var adminPassword = app.Configuration["AdminPassword"];
    Guard.Against.Null(adminEmail);
    Guard.Against.Null(adminPassword);
    await app.InitialiseDatabaseAsync(adminEmail, adminPassword);
}
else
{
    app.UseExceptionHandler("/Error", createScopeForErrors: true);
    // The default HSTS value is 30 days. You may want to change this for production scenarios, see https://aka.ms/aspnetcore-hsts.
    app.UseHsts();
}

app.UseHttpsRedirection();
app.UseAntiforgery();

app.MapStaticAssets();
app.MapRazorComponents<App>()
    .AddInteractiveWebAssemblyRenderMode()
    .AddAdditionalAssemblies(typeof(Aromata.Web.Client._Imports).Assembly);
app.UseExceptionHandler(options => { });
app.MapEndpoints();
// Add additional endpoints required by the Identity /Account Razor components.

app.Run();