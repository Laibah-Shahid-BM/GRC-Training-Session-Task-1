using BookLinqLab.Data;
using BookLinqLab.Models;

namespace BookLinqLab.Services;

public class BookService : IBookService
{
    public IEnumerable<Book> GetAll() => InMemoryStore.Books;

    public Book? GetById(int id) =>
        InMemoryStore.Books.FirstOrDefault(b => b.Id == id);

    public Book Create(Book book)
    {
        book.Id = InMemoryStore.Books.Count == 0
            ? 1
            : InMemoryStore.Books.Max(b => b.Id) + 1;

        InMemoryStore.Books.Add(book);
        return book;
    }

    public Book? Update(int id, Book updated)
    {
        var existing = InMemoryStore.Books.FirstOrDefault(b => b.Id == id);
        if (existing is null) return null;

        existing.Title = updated.Title;
        existing.Year = updated.Year;
        existing.PageCount = updated.PageCount;
        existing.AuthorId = updated.AuthorId;
        return existing;
    }

    public bool Delete(int id)
    {
        var existing = InMemoryStore.Books.FirstOrDefault(b => b.Id == id);
        if (existing is null) return false;

        InMemoryStore.Books.Remove(existing);
        return true;
    }
}