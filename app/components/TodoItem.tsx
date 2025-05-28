import React from 'react';
import { Button } from '@/app/components/ui/button';
import { Checkbox } from '@/app/components/ui/checkbox';
import { cn } from '@/app/lib/utils';
import { Id } from '@/convex/_generated/dataModel';

interface TodoItemProps {
  id: Id<"todos">;
  text: string;
  completed: boolean;
  onToggle: (id: Id<"todos">) => void;
  onDelete: (id: Id<"todos">) => void;
}

export const TodoItem: React.FC<TodoItemProps> = ({
  id,
  text,
  completed,
  onToggle,
  onDelete,
}) => {
  return (
    <div className="flex items-center justify-between p-4 border border-border rounded-md mb-2">
      <div className="flex items-center gap-3">
        <Checkbox
          id={`todo-${String(id)}`}
          checked={completed}
          onCheckedChange={() => onToggle(id)}
        />
        <label
          htmlFor={`todo-${String(id)}`}
          className={cn(
            "text-sm font-medium leading-none peer-disabled:cursor-not-allowed peer-disabled:opacity-70",
            completed && "line-through text-muted-foreground"
          )}
        >
          {text}
        </label>
      </div>
      <Button
        variant="ghost"
        size="sm"
        onClick={() => onDelete(id)}
        className="text-destructive hover:text-destructive/80 hover:bg-destructive/10"
      >
        Delete
      </Button>
    </div>
  );
}; 