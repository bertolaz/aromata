namespace Aromata.Application.Recipes.GetRecipes;

public class RecipeDto
{
    public string? Title { get; set; }
    public string? Category { get; set; }
    public int? Page { get; set; }
    public Guid BookId { get; set; }
    
    public DateTimeOffset Created { get; set; }
}