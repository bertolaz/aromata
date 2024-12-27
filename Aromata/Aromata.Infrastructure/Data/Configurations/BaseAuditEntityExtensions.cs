using Aromata.Domain.Common;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace Aromata.Infrastructure.Data.Configurations;

public static class BaseAuditEntityExtensions
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
}