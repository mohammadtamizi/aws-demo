import React, { useState } from 'react';
import { Button } from '@/app/components/ui/button';
import { TodoItem } from '@/app/components/TodoItem';
import { Dialog, DialogContent, DialogHeader, DialogTitle, DialogTrigger } from '@/app/components/ui/dialog';
import { Separator } from '@/app/components/ui/separator';
import { Label } from '@/app/components/ui/label';
import { useMutation, useQuery } from 'convex/react';
import { api } from '@/convex/_generated/api';
import { useUser } from '@clerk/clerk-react';
import { Id } from '@/convex/_generated/dataModel';

export const TodoList: React.FC = () => {
  const { user } = useUser();
  const userId = user?.id || '';

  const todos = useQuery(api.todos.get, { userId });
  const addTodo = useMutation(api.todos.add);
  const toggleTodo = useMutation(api.todos.toggle);
  const removeTodo = useMutation(api.todos.remove);

  const [newTodoText, setNewTodoText] = useState('');
  const [isDialogOpen, setIsDialogOpen] = useState(false);

  const handleAddTodo = async () => {
    if (newTodoText.trim() === '' || !user) return;

    await addTodo({ text: newTodoText, userId });
    setNewTodoText('');
    setIsDialogOpen(false);
  };

  const handleToggleTodo = async (id: Id<"todos">) => {
    await toggleTodo({ id });
  };

  const handleDeleteTodo = async (id: Id<"todos">) => {
    await removeTodo({ id });
  };

  if (!user) {
    return (
      <div className="text-center py-10">
        <h2 className="text-xl">Please sign in to manage your todos</h2>
      </div>
    );
  }

  return (
    <div className="max-w-md mx-auto p-4">
      <div className="flex items-center justify-between mb-6">
        <h1 className="text-2xl font-bold">Todo List</h1>
        <Dialog open={isDialogOpen} onOpenChange={setIsDialogOpen}>
          <DialogTrigger asChild>
            <Button>Add Todo</Button>
          </DialogTrigger>
          <DialogContent>
            <DialogHeader>
              <DialogTitle>Add a new todo</DialogTitle>
            </DialogHeader>
            <div className="grid gap-4 py-4">
              <div className="grid gap-2">
                <Label htmlFor="todo-text">Task</Label>
                <input
                  id="todo-text"
                  value={newTodoText}
                  onChange={(e) => setNewTodoText(e.target.value)}
                  className="flex h-10 w-full rounded-md border border-input bg-background px-3 py-2 text-sm ring-offset-background file:border-0 file:bg-transparent file:text-sm file:font-medium placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-2 focus-visible:ring-ring focus-visible:ring-offset-2 disabled:cursor-not-allowed disabled:opacity-50"
                  placeholder="Enter your task..."
                  onKeyDown={(e) => {
                    if (e.key === 'Enter') {
                      handleAddTodo();
                    }
                  }}
                />
              </div>
            </div>
            <div className="flex justify-end">
              <Button onClick={handleAddTodo}>Add Task</Button>
            </div>
          </DialogContent>
        </Dialog>
      </div>

      <Separator className="my-4" />

      <div className="space-y-2">
        {!todos || todos.length === 0 ? (
          <p className="text-center text-muted-foreground py-4">No todos yet. Add some!</p>
        ) : (
          todos.map((todo) => (
            <TodoItem
              key={todo._id}
              id={todo._id}
              text={todo.text}
              completed={todo.completed}
              onToggle={handleToggleTodo}
              onDelete={handleDeleteTodo}
            />
          ))
        )}
      </div>
    </div>
  );
};
