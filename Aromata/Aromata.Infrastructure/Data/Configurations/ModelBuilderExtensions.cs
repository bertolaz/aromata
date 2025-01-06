using Aromata.Domain.Common;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aromata.Infrastructure.Data.Configurations;

public static class ModelBuilderExtensions
{
    public static void ConfigureAudit<T>(this EntityTypeBuilder<T> entityTypeBuilder) where T : BaseAuditableEntity
    {
        entityTypeBuilder.Property(x => x.CreatedBy)
            .HasMaxLength(50);

        entityTypeBuilder.Property(x => x.Created);

        entityTypeBuilder.Ignore(x => x.DomainEvents);
        entityTypeBuilder.Property(x => x.LastModified);
        entityTypeBuilder.Property(x => x.LastModifiedBy)
            .HasMaxLength(50);
    }

    public static PropertyBuilder<TProperty> UseCaseInsensitiveCollation<TProperty>(
        this PropertyBuilder<TProperty> propertyBuilder)
        => propertyBuilder.UseCollation(Collations.CaseInsensitive);

    public static void ConfigureAppCollations(this ModelBuilder modelBuilder)
    {
        modelBuilder.HasCollation(Collations.CaseInsensitive, locale: "en-u-ks-primary", provider: "icu",
            deterministic: false);
    }
}