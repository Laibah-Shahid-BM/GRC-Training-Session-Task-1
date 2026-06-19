namespace BookLinqLab.Models;

public class Author
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<Book> Books { get; set; } = new List<Book>();
}

public class Book
{
    public int Id { get; set; }
    public string Title { get; set; } = string.Empty;
    public int Year { get; set; }
    public int PageCount { get; set; }
    public int AuthorId { get; set; }                 
    public Author Author { get; set; } = null!;      
    public ICollection<BookTag> BookTags { get; set; } = new List<BookTag>();
}

public class Tag
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public ICollection<BookTag> BookTags { get; set; } = new List<BookTag>();
}

public class BookTag  
{
    public int BookId { get; set; }
    public Book Book { get; set; } = null!;
    public int TagId { get; set; }
    public Tag Tag { get; set; } = null!;
}