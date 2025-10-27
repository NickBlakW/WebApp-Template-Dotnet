generate-service-files service: (_generate-csproj service) (_generate-cs-model service)
    dotnet sln add {{service}}/{{service}}.csproj
    dotnet restore

# Generates a standard .csproj file for given service
_generate-csproj name:
    mkdir {{name}}
    # Init
    echo "<Project Sdk=\"Microsoft.NET.Sdk.Web\">" >> {{name}}/{{name}}.csproj
    # Setup
    sed -i "$ a \ \t<PropertyGroup>\n\t\t<TargetFramework>net8.0</TargetFramework>\n\t\t<DockerDefaultTargetOS>linux</DockerDefaultTargetOS>\n\t</PropertyGroup>\n" {{name}}/{{name}}.csproj
    # Dependencies
    sed -i "$ a \ \t<ItemGroup>\n\t\t<PackageReference Include=\"Microsoft.EntityFrameworkCore\" Version=\"8.0.0\" />" {{name}}/{{name}}.csproj
    sed -i "$ a \ \t\t<PackageReference Include=\"Microsoft.AspNetCore.Authentication.JwtBearer\" Version=\"8.0.0\" />" {{name}}/{{name}}.csproj
    sed -i "$ a \ \t\t<PackageReference Include=\"Swashbuckle.AspNetCore\" Version=\"6.0.0\" />" {{name}}/{{name}}.csproj
    sed -i "$ a \ \t</ItemGroup>" {{name}}/{{name}}.csproj
    #End init
    echo "</Project>" >> {{name}}/{{name}}.csproj

# Generate standard model stripping 'Service' from '...Service' leaving the model name
# Created as a just compliant shell script
_generate-cs-model service:
    #!/bin/sh
    # Create base model
    model_name="$(echo {{service}} | sed 's/\Service//g')"
    echo "public class ${model_name}" >> {{service}}/$model_name.cs
    sed -i "$ a {\n\tpublic int Id { get; set; }\n\n}" {{service}}/$model_name.cs
    # Create service database context 
    ctx_name="${model_name}Context"
    echo "using Microsoft.EntityFrameworkCore;" >> {{service}}/$ctx_name.cs
    sed -i "$ a \ \npublic class ${ctx_name} : DbContext\n{\n\tpublic ${ctx_name}(DbContextOptions<${ctx_name}> opt) : base(opt) {}\n\tpublic DbSet<${model_name}> ${model_name}s => Set<${model_name}>();\n}" {{service}}/$ctx_name.cs
    # Create Basic controller
    ctrl_path={{service}}/controllers
    ctrl=$ctrl_path/"${model_name}Controller.cs"
    ctrl_name="${model_name}Controller"
    mkdir $ctrl_path
    echo "using Microsoft.AspNetCore.Mvc;" >> $ctrl
    sed -i "$ a using Microsoft.EntityFrameworkCore;\n\n[ApiController]\n[Route(\"[controller]\")]\npublic class ${ctrl_name} : ControllerBase\n{" $ctrl
    sed -i "$ a \ \tprivate readonly ${ctx_name} _context;\n\n\tpublic ${ctrl_name}(${ctx_name} ctx) {\n\t_context = ctx;\n\t}\n" $ctrl
    sed -i "$ a \ \t[HttpGet]\n\tpublic async Task<IActionResult> Get()\n\t{\n\t\tvar resultList = await _context.${model_name}s.ToListAsync();\n\t\treturn Ok(resultList);\n\t}\n" $ctrl
    sed -i "$ a \ \t[HttpPost]\n\tpublic async Task<IActionResult> Post([FromBody] ${model_name} newModel)\n\t{\n\t\t_context.${model_name}s.Add(newModel);\n\t\tawait _context.SaveChangesAsync();\n\t\treturn CreatedAtAction(nameof(Get), new { id = newModel.Id }, newModel);\n\t}\n}" $ctrl
    # Create default Program.cs
    echo "var builder = WebApplication.CreateBuilder(args);" >> {{service}}/Program.cs
    sed -i "$ a builder.Services.AddControllers();\nbuilder.Services.AddEndpointsApiExplorer();\nbuilder.Services.AddSwaggerGen();\n\n" {{service}}/Program.cs
    sed -i "$ a builder.Services.AddDbContext<${ctx_name}>(opt => \n\topt.UseMySql(\n\t\tbuilder.Configuration.GetConnectionString(\"DefaultConnection\"),\n\t\tServerVersion.AutoDetect(builder.Configuration.GetConnectionString(\"DefaultConnection\"))));\n" {{service}}/Program.cs
    sed -i "$ a var app = builder.Build();\n" {{service}}/Program.cs
    sed -i "$ a if (app.Environment.IsDevelopment())\n{\n\tapp.UseSwagger();\n\tapp.UseSwaggerUI();\n}\n\napp.MapControllers();\n" {{service}}/Program.cs
    sed -i "$ a using (var scope = app.Services.CreateScope())\n{\n\tvar db = scope.ServiceProvider.GetRequiredService<${ctx_name}>();\n\tdb.Database.Migrate();\n}\n" {{service}}/Program.cs
    sed -i "$ a app.Run();" {{service}}/Program.cs