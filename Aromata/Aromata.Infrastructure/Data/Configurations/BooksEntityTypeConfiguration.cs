using Aromata.Domain.Books;
using Aromata.Domain.Recipes;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aromata.Infrastructure.Data.Configurations;

public class BooksEntityTypeConfiguration : IEntityTypeConfiguration<Book>
{
    public void Configure(EntityTypeBuilder<Book> builder)
    {
        builder.HasKey(x => x.Id);
        
        builder.Property(x => x.Title)
            .HasMaxLength(150);
        builder.Property(x => x.Author)
            .HasMaxLength(150);
        
        builder.ConfigureAudit();

        builder.HasMany<Recipe>()
            .WithOne()
            .HasForeignKey(x => x.BookId)
            .OnDelete(DeleteBehavior.Cascade);
        
    }
    
}