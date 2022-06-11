
var builder = WebApplication.CreateBuilder(args);

#if DEBUG
  builder.Services.AddSassCompiler();
#endif

var app = builder.Build();

app.MapGet("/ping", () => "pong");

app.UseFileServer();

app.Run("http://*:80");
