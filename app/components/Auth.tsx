import React from 'react';
import { Button } from './ui/button';

export const Auth: React.FC = () => {
  return (
    <div className="flex justify-between items-center p-4 bg-primary/10">
      <h1 className="text-xl font-bold">AWS Demo App</h1>
      <Button variant="outline" size="sm" onClick={() => window.open('https://aws.amazon.com', '_blank')}>
        Learn More
      </Button>
    </div>
  );
}; 