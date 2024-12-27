using FluentValidation;

namespace Aromata.Application.Recipes.UpdateRecipe;

public class UpdateRecipeCommandValidator : AbstractValidator<UpdateRecipeCommand>
{
    public UpdateRecipeCommandValidator()
    {
        RuleFor(x => x.Page)
            .GreaterThan(0)
            .Unless(x => x.Page is null);

        RuleFor(x => x.Title)
            .NotEmpty()
            .MaximumLength(150);
        
    }
}