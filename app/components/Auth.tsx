/**
 * Auth Component
 *
 * A simplified header component that displays the app title and a "Learn More" button
 * In a real application, this component would handle authentication logic
 * Currently it only provides basic navigation and branding
 */
import React from 'react';
import { Button } from './ui/button';

/**
 * Auth Component
 *
 * @returns {JSX.Element} Header with app title and a button that links to AWS website
 */
export const Auth: React.FC = () => {
  return (
    <div className="flex justify-between items-center p-4 bg-primary/10">
      {/* App title/logo */}
      <h1 className="text-xl font-bold">AWS Demo App</h1>

      {/* External link to AWS website */}
      <Button
        variant="outline"
        size="sm"
        onClick={() => window.open('https://aws.amazon.com', '_blank')}
      >
        Learn More
      </Button>
    </div>
  );
};
