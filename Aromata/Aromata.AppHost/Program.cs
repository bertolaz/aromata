using Projects;

var builder = DistributedApplication.CreateBuilder(args);

var databaseName = "AromataDb";
var adminEmail = builder.Configuration["AdminEmail"];
var adminPassword = builder.Configuration["AdminPassword"];
var postgres =
        builder.AddPostgres("postgres")
            //This optional environment variable can be used to define a different name
            //for the default database that is created when the image is first started.
            .WithEnvironment("POSTGRES_DB", databaseName)
            .WithDataVolume()
            .WithPgWeb();
var database = postgres.AddDatabase(databaseName);

builder.AddProject<Aromata_Web>("web")
    .WithReference(database)
    .WithEnvironment("AdminEmail", adminEmail)
    .WithEnvironment("AdminPassword", adminPassword)
    .WaitFor(database);


builder.Build().Run();