using Aromata.Web.Client;
using Microsoft.AspNetCore.Components;
using Microsoft.AspNetCore.Components.WebAssembly.Hosting;
using MudBlazor.Services;

var builder = WebAssemblyHostBuilder.CreateDefault(args);

builder.Services.AddAuthorizationCore();
builder.Services.AddMudServices();
builder.Services.AddCascadingAuthenticationState();
builder.Services.AddAuthenticationStateDeserialization();
builder.Services.AddScoped<ErrorHandler>();
builder.Services.AddCascadingValue(sp =>
{
    var errorHandler = sp.GetRequiredService<ErrorHandler>();
    var s = new CascadingValueSource<ErrorHandler>(errorHandler, isFixed: true);
    return s;
});
builder.Services.AddScoped(sp => new HttpClient()
{
    BaseAddress = new Uri(builder.HostEnvironment.BaseAddress)
});

await builder.Build().RunAsync();