using Microsoft.AspNetCore.Authentication.JwtBearer;
using Yarp.ReverseProxy;

var builder = WebApplication.CreateBuilder(args);

// Token-baseret auth
builder.Services.AddAuthentication("MyScheme")
    .AddJwtBearer("MyScheme", options =>
    {
        options.Events = new JwtBearerEvents
        {
            OnMessageReceived = context =>
            {
                var token = context.Request.Headers["Authorization"];
                if (token == "Bearer demo-token")
                {
                    context.Principal = new System.Security.Claims.ClaimsPrincipal(
                        new System.Security.Claims.ClaimsIdentity("MyScheme")
                    );
                    context.Success();
                }
                return Task.CompletedTask;
            }
        };
    });

builder.Services.AddAuthorization();

builder.Services.AddReverseProxy()
    .LoadFromConfig(builder.Configuration.GetSection("ReverseProxy"));

var app = builder.Build();

app.UseStaticFiles();
app.UseAuthentication();
app.UseAuthorization();

app.MapReverseProxy().RequireAuthorization();

app.Run();
