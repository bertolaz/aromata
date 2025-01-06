using Aromata.Domain.Recipes;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aromata.Infrastructure.Data.Configurations;

public class RecipeEntityTypeConfiguration : IEntityTypeConfiguration<Recipe>
{
    public void Configure(EntityTypeBuilder<Recipe> builder)
    {
        builder.ToTable("Recipes");

        builder.ConfigureAudit();

        builder.HasKey(x => x.Id);

        builder.Property(x => x.Category)
            .HasMaxLength(150);

        builder.Property(x => x.Title)
            .HasMaxLength(150);

        builder.Property(x => x.BookId).IsRequired();
    }
}